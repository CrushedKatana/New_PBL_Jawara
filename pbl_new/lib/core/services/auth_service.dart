import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pbl_new/config/api_config.dart';
import 'package:pbl_new/core/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static UserModel? _currentUser;
  
  static UserModel? get currentUser => _currentUser;

  Map<String, dynamic> _decodeJsonResponse(http.Response response, {required String context}) {
    final contentType = (response.headers['content-type'] ?? '').toLowerCase();
    final body = response.body;

    final trimmed = body.trimLeft();
    final looksLikeJson = trimmed.startsWith('{') || trimmed.startsWith('[');
    if (!contentType.contains('application/json') && !looksLikeJson) {
      final snippet = body.length > 300 ? body.substring(0, 300) : body;
      return {
        'success': false,
        'error': 'Server mengembalikan response non-JSON ($context). Status: ${response.statusCode}. Body: $snippet',
      };
    }

    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {
        'success': false,
        'error': 'Response JSON tidak valid ($context): expected object',
      };
    } catch (e) {
      final snippet = body.length > 300 ? body.substring(0, 300) : body;
      return {
        'success': false,
        'error': 'Gagal parse JSON ($context). Status: ${response.statusCode}. Error: $e. Body: $snippet',
      };
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.authEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        ApiConfig.timeout,
        onTimeout: () {
          throw Exception('Request timeout - check your internet connection');
        },
      );

      final data = _decodeJsonResponse(response, context: 'login');

      if (response.statusCode == 200 && data['success'] == true) {
        _currentUser = UserModel.fromJson(data['data']);
        await _saveUserSession(_currentUser!);
        return {'success': true, 'user': _currentUser};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Login failed'};
      }
    } on Exception catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('timeout')) {
        return {'success': false, 'error': 'Koneksi timeout. Cek internet Anda.'};
      } else if (errorMsg.contains('SocketException') || errorMsg.contains('Failed host lookup')) {
        return {'success': false, 'error': 'Tidak dapat terhubung ke server. Pastikan PC backend menyala dan HP terhubung WiFi yang sama.'};
      }
      return {'success': false, 'error': 'Error koneksi: ${e.toString()}'};
    } catch (e) {
      return {'success': false, 'error': 'Error tidak terduga: $e'};
    }
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
    String? rt,
    String? rw,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.authEndpoint}?action=register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone ?? '',
          'address': address ?? '',
          'rt': rt ?? '',
          'rw': rw ?? '',
        }),
      ).timeout(ApiConfig.timeout);

      final data = _decodeJsonResponse(response, context: 'register');

      if (response.statusCode == 201 && data['success'] == true) {
        _currentUser = UserModel.fromJson(data['data']);
        await _saveUserSession(_currentUser!);
        return {'success': true, 'user': _currentUser};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  // Get User Profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.authEndpoint}?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.timeout);

      final data = _decodeJsonResponse(response, context: 'getUserProfile');

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'user': UserModel.fromJson(data['data'])};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to get profile'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  // Update Profile
  Future<Map<String, dynamic>> updateProfile(UserModel user) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.authEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user.toJson()),
      ).timeout(ApiConfig.timeout);

      final data = _decodeJsonResponse(response, context: 'updateProfile');

      if (response.statusCode == 200 && data['success'] == true) {
        _currentUser = user;
        await _saveUserSession(user);
        return {'success': true};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Update failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  // Logout
  static Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    if (_currentUser != null) return true;
    
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_session');
    
    if (userJson != null) {
      _currentUser = UserModel.fromJson(json.decode(userJson));
      return true;
    }
    
    return false;
  }

  // Save user session
  Future<void> _saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_session', json.encode(user.toJson()));
  }

  // Restore user session
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_session');
    
    if (userJson != null) {
      _currentUser = UserModel.fromJson(json.decode(userJson));
    }
  }
}
