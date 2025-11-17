import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String sellerRtRw;
  final bool sellerVerified;
  final String name;
  final String category;
  final double price;
  final String? size;
  final String condition;
  final String description;
  final List<String> imageUrls;
  final String status; // 'aktif', 'pending', 'terjual'
  final int viewCount;
  final int chatCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isNew;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.sellerRtRw,
    this.sellerVerified = false,
    required this.name,
    required this.category,
    required this.price,
    this.size,
    required this.condition,
    required this.description,
    required this.imageUrls,
    this.status = 'pending',
    this.viewCount = 0,
    this.chatCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isNew = false,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      sellerRtRw: data['sellerRtRw'] ?? '',
      sellerVerified: data['sellerVerified'] ?? false,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      size: data['size'],
      condition: data['condition'] ?? '',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      status: data['status'] ?? 'pending',
      viewCount: data['viewCount'] ?? 0,
      chatCount: data['chatCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isNew: data['isNew'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerRtRw': sellerRtRw,
      'sellerVerified': sellerVerified,
      'name': name,
      'category': category,
      'price': price,
      'size': size,
      'condition': condition,
      'description': description,
      'imageUrls': imageUrls,
      'status': status,
      'viewCount': viewCount,
      'chatCount': chatCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isNew': isNew,
    };
  }
}
