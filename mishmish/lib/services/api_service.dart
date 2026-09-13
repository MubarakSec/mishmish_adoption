import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

/// Thin HTTP layer over the Laravel REST API (Android + iOS only).
///
/// Uses [AppConfig] for host/timeouts so the base URL is defined once.
/// Auth token + cached profile fields persist in SharedPreferences.
class ApiService {
  ApiService._();

  static String get baseUrl => AppConfig.baseUrl;

  static Future<http.Response> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(AppConfig.requestTimeout);
    } catch (_) {
      // Android emulator cannot reach host localhost: fall back to 10.0.2.2.
      if (defaultTargetPlatform == TargetPlatform.android &&
          AppConfig.activeHost == '127.0.0.1' &&
          AppConfig.overrideHost == null) {
        AppConfig.activeHost = '10.0.2.2';
        return await request().timeout(AppConfig.requestTimeout);
      }
      rethrow;
    }
  }

  static Future<http.Response> _post(String endpoint,
          {Map<String, String>? headers, Object? body}) =>
      _send(() => http.post(Uri.parse('$baseUrl$endpoint'),
          headers: headers, body: body));

  static Future<http.Response> _get(String endpoint,
          {Map<String, String>? headers}) =>
      _send(() => http.get(Uri.parse('$baseUrl$endpoint'), headers: headers));

  static String? _token;

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConfig.keyAuthToken);
    return _token;
  }

  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.keyAuthToken, token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.keyAuthToken);
    await prefs.remove(AppConfig.keyUserName);
    await prefs.remove(AppConfig.keyUserEmail);
  }

  static Future<void> saveUser(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.keyUserName, name);
    await prefs.setString(AppConfig.keyUserEmail, email);
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await _post(
      '/register',
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password
      }),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await _post(
      '/login',
      headers: await _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  static Future<void> logout() async {
    await _post('/logout', headers: await _headers());
    await clearToken();
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await _post(
      '/forgot-password',
      headers: await _headers(),
      body: jsonEncode({'email': email}),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> verifyCode(
      String email, String code) async {
    final response = await _post(
      '/verify-code',
      headers: await _headers(),
      body: jsonEncode({'email': email, 'code': code}),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> resetPassword(
      String email, String password, String code) async {
    final response = await _post(
      '/reset-password',
      headers: await _headers(),
      body: jsonEncode({
        'email': email,
        'code': code,
        'password': password,
        'password_confirmation': password,
      }),
    );
    return _handleResponse(response);
  }

  static Future<List<dynamic>> getKittens() async {
    final response = await _get('/kittens', headers: await _headers());
    final data = _handleResponse(response);
    return data is List ? data : [];
  }

  static Future<List<dynamic>> getFavorites() async {
    final response = await _get('/favorites', headers: await _headers());
    final data = _handleResponse(response);
    return data is List ? data : [];
  }

  static Future<bool> toggleFavorite(int kittenId) async {
    final response = await _post(
      '/favorites/$kittenId',
      headers: await _headers(),
    );
    final data = _handleResponse(response);
    return data['is_favorite'] ?? false;
  }

  static dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      if (response.statusCode >= 500) {
        throw Exception(
            'خطأ في خادم النظام (${response.statusCode})، يرجى المحاولة لاحقاً');
      }
      throw Exception('استجابة غير صالحة من الخادم (${response.statusCode})');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    if (body is Map && body.containsKey('errors')) {
      final errors = body['errors'] as Map<String, dynamic>;
      final firstMsg = errors.values.expand((e) => e as List).firstOrNull;
      if (firstMsg != null) throw Exception(firstMsg.toString());
    }

    throw Exception(body is Map && body.containsKey('message')
        ? body['message']
        : 'حدث خطأ غير متوقع');
  }
}
