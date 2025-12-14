import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pbl_new/config/api_config.dart';

/// Service untuk profile management
class ProfileService {
  static String get _endpoint => '${ApiConfig.baseUrl}/profile.php';

  /// Get user profile data
  static Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        body: {
          'action': 'get_profile',
          'user_id': userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to load profile'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }

  /// Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      final Map<String, String> body = {
        'action': 'update_profile',
        'user_id': userId.toString(),
      };

      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (address != null) body['address'] = address;

      final response = await http.post(
        Uri.parse(_endpoint),
        body: body,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to update profile'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }

  /// Get user statistics
  static Future<Map<String, dynamic>> getUserStats(int userId) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        body: {
          'action': 'get_stats',
          'user_id': userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to load statistics'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }

  /// Change password
  static Future<Map<String, dynamic>> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        body: {
          'action': 'change_password',
          'user_id': userId.toString(),
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to change password'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }
}
