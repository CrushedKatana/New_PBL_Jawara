import 'package:cloud_firestore/cloud_firestore.dart';

/// Central access point for Firestore collections.
/// Mirrors existing backend tables (auth_users, products, categories, chat_messages, transactions, ml_detections, rt_metrics_activities)
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  CollectionReference get users => _db.collection('users');
  CollectionReference get products => _db.collection('products');
  CollectionReference get categories => _db.collection('categories');
  CollectionReference get chats => _db.collection('chat_messages');
  CollectionReference get transactions => _db.collection('transactions');
  CollectionReference get detections => _db.collection('ml_detections');
  CollectionReference get rtMetrics => _db.collection('rt_metrics_activities');

  // Example CRUD for a product
  Future<DocumentReference> addProduct(Map<String, dynamic> data) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    return products.add(data);
  }

  Stream<QuerySnapshot> watchLatestProducts({int limit = 20}) {
    return products.orderBy('createdAt', descending: true).limit(limit).snapshots();
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await products.doc(id).update(data);
  }

  Future<void> deleteProduct(String id) async {
    await products.doc(id).delete();
  }
}
