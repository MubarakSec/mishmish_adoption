import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Manual override if needed:
  // static String? overrideHost = '192.168.1.100';
  static String? overrideHost;
  static String _activeHost = '127.0.0.1';

  static String get baseUrl {
    if (overrideHost != null && overrideHost!.isNotEmpty) {
      return 'http://$overrideHost:8000/api';
    }
    return 'http://$_activeHost:8000/api';
  }

  static Future<http.Response> _post(String endpoint, {Map<String, String>? headers, Object? body}) async {
    try {
      return await http
          .post(Uri.parse('$baseUrl$endpoint'), headers: headers, body: body)
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android && _activeHost == '127.0.0.1') {
        _activeHost = '10.0.2.2';
        return await http.post(Uri.parse('$baseUrl$endpoint'), headers: headers, body: body);
      }
      rethrow;
    }
  }

  static Future<http.Response> _get(String endpoint, {Map<String, String>? headers}) async {
    try {
      return await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android && _activeHost == '127.0.0.1') {
        _activeHost = '10.0.2.2';
        return await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
      }
      rethrow;
    }
  }
  static String? _token;

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
  }

  static Future<void> saveUser(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await _post(
      '/register',
      headers: await _headers(),
      body: jsonEncode({'name': name, 'email': email, 'password': password, 'password_confirmation': password}),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
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

  static Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    final response = await _post(
      '/verify-code',
      headers: await _headers(),
      body: jsonEncode({'email': email, 'code': code}),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> resetPassword(String email, String password, String code) async {
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
        throw Exception('خطأ في خادم النظام (${response.statusCode})، يرجى المحاولة لاحقاً');
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

    throw Exception(body is Map && body.containsKey('message') ? body['message'] : 'حدث خطأ غير متوقع');
  }
}
