class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? actionType;
  final String? actionId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.actionType,
    this.actionId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      actionType: json['action_type']?.toString(),
      actionId: json['action_id']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'is_read': isRead ? 1 : 0,
      'action_type': actionType,
      'action_id': actionId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
