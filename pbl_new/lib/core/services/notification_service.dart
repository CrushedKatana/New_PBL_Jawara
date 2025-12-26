import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../models/notification_model.dart';
import 'auth_service.dart';

/// Service untuk mengelola notifikasi
class NotificationService {
  static String get _endpoint => '${ApiConfig.baseUrl}/notifications.php';

  /// Fetch semua notifikasi
  Future<List<NotificationModel>> fetchAllNotifications() async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$_endpoint?user_id=${currentUser.id}'),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List notifications = data['notifications'] ?? [];
          return notifications.map((n) => NotificationModel.fromJson(n)).toList();
        }
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
    return [];
  }

  /// Fetch notifikasi berdasarkan filter (Semua, Pesanan, Pesan)
  Future<List<NotificationModel>> fetchNotificationsByFilter(String filter) async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$_endpoint?user_id=${currentUser.id}&filter=$filter'),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List notifications = data['notifications'] ?? [];
          return notifications.map((n) => NotificationModel.fromJson(n)).toList();
        }
      }
    } catch (e) {
      print('Error fetching filtered notifications: $e');
    }
    return [];
  }

  /// Tandai notifikasi sebagai sudah dibaca
  Future<bool> markAsRead(String notificationId) async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return false;

    try {
      final response = await http.put(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': notificationId,
          'user_id': currentUser.id,
        }),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
    return false;
  }

  /// Tandai semua notifikasi sebagai sudah dibaca
  Future<bool> markAllAsRead() async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return false;

    try {
      final response = await http.put(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': currentUser.id,
          'mark_all': true,
        }),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error marking all as read: $e');
    }
    return false;
  }

  /// Hitung jumlah notifikasi yang belum dibaca
  Future<int> getUnreadCount() async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return 0;

    try {
      final response = await http.get(
        Uri.parse('$_endpoint?action=count&user_id=${currentUser.id}'),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['count'] ?? 0;
        }
      }
    } catch (e) {
      print('Error getting unread count: $e');
    }
    return 0;
  }

  /// Create a new notification (for testing or admin)
  Future<bool> createNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'general',
    String? relatedId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'title': title,
          'message': message,
          'type': type,
          'related_id': relatedId,
          'data': data,
        }),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      }
    } catch (e) {
      print('Error creating notification: $e');
    }
    return false;
  }
}
