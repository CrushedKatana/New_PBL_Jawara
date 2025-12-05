/// Model untuk notifikasi aplikasi
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String timeAgo;
  final bool isRead;
  final String? orderId;
  final String? senderId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timeAgo,
    this.isRead = false,
    this.orderId,
    this.senderId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: NotificationType.fromString(json['type'] ?? 'other'),
      timeAgo: json['time_ago'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      orderId: json['order_id']?.toString(),
      senderId: json['sender_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.value,
      'time_ago': timeAgo,
      'is_read': isRead ? 1 : 0,
      'order_id': orderId,
      'sender_id': senderId,
    };
  }
}

/// Tipe-tipe notifikasi
enum NotificationType {
  order('order'),          // Pesanan dikirim
  message('message'),      // Pesan baru
  payment('payment'),      // Pembayaran berhasil
  verification('verification'), // Verifikasi RT/RW
  update('update'),        // Update aplikasi
  views('views'),          // Produk dilihat
  unread('unread'),        // Pesan belum dibaca
  other('other');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'order':
      case 'pesanan':
        return NotificationType.order;
      case 'message':
      case 'pesan':
        return NotificationType.message;
      case 'payment':
      case 'pembayaran':
        return NotificationType.payment;
      case 'verification':
      case 'verifikasi':
        return NotificationType.verification;
      case 'update':
        return NotificationType.update;
      case 'views':
        return NotificationType.views;
      case 'unread':
        return NotificationType.unread;
      default:
        return NotificationType.other;
    }
  }
}
