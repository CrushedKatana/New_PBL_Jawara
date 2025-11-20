import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/message_model.dart';

class ChatService {
  // Get conversation list
  Future<List<MessageModel>> getConversations(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.chatEndpoint}?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<MessageModel> messages = [];
          for (var item in data['data']) {
            messages.add(MessageModel.fromJson(item));
          }
          return messages;
        }
      }
      return [];
    } catch (e) {
      print('Error getting conversations: $e');
      return [];
    }
  }

  // Get messages with specific user
  Future<List<MessageModel>> getMessages(String userId, String conversationWith) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.chatEndpoint}?user_id=$userId&conversation_with=$conversationWith'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<MessageModel> messages = [];
          for (var item in data['data']) {
            messages.add(MessageModel.fromJson(item));
          }
          return messages;
        }
      }
      return [];
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  // Send message
  Future<Map<String, dynamic>> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
    String? productId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.chatEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'message': message,
          'product_id': productId,
        }),
      ).timeout(ApiConfig.timeout);

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true, 'id': data['data']['id']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to send message'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  // Mark messages as read
  Future<Map<String, dynamic>> markAsRead(String userId, String conversationWith) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.chatEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'conversation_with': conversationWith,
        }),
      ).timeout(ApiConfig.timeout);

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to mark as read'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }
}
