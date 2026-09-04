import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // For physical devices over Wi-Fi, set your PC's LAN IP here:
  // static String? overrideHost = '192.168.1.100';
  static String? overrideHost;

  static String get baseUrl {
    if (overrideHost != null && overrideHost!.isNotEmpty) {
      return 'http://$overrideHost:8000/api';
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // 10.0.2.2 connects to host localhost on standard Android Emulator
        return 'http://10.0.2.2:8000/api';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'http://127.0.0.1:8000/api';
      default:
        return 'http://10.0.2.2:8000/api';
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
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: await _headers(),
      body: jsonEncode({'name': name, 'email': email, 'password': password, 'password_confirmation': password}),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: await _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  static Future<void> logout() async {
    await http.post(Uri.parse('$baseUrl/logout'), headers: await _headers());
    await clearToken();
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: await _headers(),
      body: jsonEncode({'email': email}),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-code'),
      headers: await _headers(),
      body: jsonEncode({'email': email, 'code': code}),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> resetPassword(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: await _headers(),
      body: jsonEncode({'email': email, 'password': password, 'password_confirmation': password}),
    );
    return _handleResponse(response);
  }

  static Future<List<dynamic>> getKittens() async {
    final response = await http.get(Uri.parse('$baseUrl/kittens'), headers: await _headers());
    final data = _handleResponse(response);
    return data is List ? data : [];
  }

  static Future<List<dynamic>> getFavorites() async {
    final response = await http.get(Uri.parse('$baseUrl/favorites'), headers: await _headers());
    final data = _handleResponse(response);
    return data is List ? data : [];
  }

  static Future<bool> toggleFavorite(int kittenId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/favorites/$kittenId'),
      headers: await _headers(),
    );
    final data = _handleResponse(response);
    return data['is_favorite'] ?? false;
  }

  static dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw Exception(body['message'] ?? 'حدث خطأ');
  }
}
