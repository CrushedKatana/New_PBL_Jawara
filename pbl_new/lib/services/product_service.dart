import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Add product
  Future<String?> addProduct({
    required ProductModel product,
    required List<File> imageFiles,
  }) async {
    try {
      // Upload images
      List<String> imageUrls = [];
      for (int i = 0; i < imageFiles.length; i++) {
        String fileName = '${product.sellerId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        Reference ref = _storage.ref().child('products/$fileName');
        await ref.putFile(imageFiles[i]);
        String downloadUrl = await ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      // Create product with image URLs
      ProductModel newProduct = ProductModel(
        id: '',
        sellerId: product.sellerId,
        sellerName: product.sellerName,
        sellerRtRw: product.sellerRtRw,
        sellerVerified: product.sellerVerified,
        name: product.name,
        category: product.category,
        price: product.price,
        size: product.size,
        condition: product.condition,
        description: product.description,
        imageUrls: imageUrls,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isNew: true,
      );

      DocumentReference docRef = await _firestore.collection('products').add(newProduct.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      return null;
    }
  }

  // Get all products
  Stream<List<ProductModel>> getProducts({String? category, String? status}) {
    Query query = _firestore.collection('products').orderBy('createdAt', descending: true);
    
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  // Get user products
  Stream<List<ProductModel>> getUserProducts(String userId) {
    return _firestore
        .collection('products')
        .where('sellerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  // Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Error getting product: $e');
    }
    return null;
  }

  // Update product
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.fromDate(DateTime.now());
    await _firestore.collection('products').doc(productId).update(data);
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  // Increment view count
  Future<void> incrementViewCount(String productId) async {
    await _firestore.collection('products').doc(productId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  // Search products
  Stream<List<ProductModel>> searchProducts(String query) {
    return _firestore
        .collection('products')
        .where('status', isEqualTo: 'aktif')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}
