class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String? productId;
  final String message;
  final bool isRead;
  final DateTime? createdAt;
  final String? senderName;
  final String? senderPhoto;
  final String? receiverName;
  final String? receiverPhoto;
  final String? productTitle;
  final String? productImage;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.productId,
    required this.message,
    this.isRead = false,
    this.createdAt,
    this.senderName,
    this.senderPhoto,
    this.receiverName,
    this.receiverPhoto,
    this.productTitle,
    this.productImage,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      senderId: json['sender_id'] ?? '',
      receiverId: json['receiver_id'] ?? '',
      productId: json['product_id'],
      message: json['message'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      senderName: json['sender_name'],
      senderPhoto: json['sender_photo'],
      receiverName: json['receiver_name'],
      receiverPhoto: json['receiver_photo'],
      productTitle: json['product_title'],
      productImage: json['product_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'product_id': productId,
      'message': message,
    };
  }
}
