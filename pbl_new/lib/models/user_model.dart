import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String role; // 'warga'
  final String? rtRw;
  final String? kelurahan;
  final bool isVerified;
  final String? photoUrl;
  final int productsSold;
  final int favoriteCount;
  final double rating;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.role,
    this.rtRw,
    this.kelurahan,
    this.isVerified = false,
    this.photoUrl,
    this.productsSold = 0,
    this.favoriteCount = 0,
    this.rating = 0.0,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      role: data['role'] ?? 'warga',
      rtRw: data['rtRw'],
      kelurahan: data['kelurahan'],
      isVerified: data['isVerified'] ?? false,
      photoUrl: data['photoUrl'],
      productsSold: data['productsSold'] ?? 0,
      favoriteCount: data['favoriteCount'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'rtRw': rtRw,
      'kelurahan': kelurahan,
      'isVerified': isVerified,
      'photoUrl': photoUrl,
      'productsSold': productsSold,
      'favoriteCount': favoriteCount,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
