import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbl_new/config/api_config.dart';
import 'package:pbl_new/core/models/product_model.dart';

class ProductService {
  // Get all products
  Future<List<ProductModel>> getProducts({
    String? sellerId,
    String? categoryId,
    String? search,
  }) async {
    try {
      String url = ApiConfig.productsEndpoint;
      List<String> params = [];
      
      if (sellerId != null) params.add('seller_id=$sellerId');
      if (categoryId != null) params.add('category_id=$categoryId');
      if (search != null) params.add('search=$search');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<ProductModel> products = [];
          for (var item in data['data']) {
            products.add(ProductModel.fromJson(item));
          }
          return products;
        }
      }
      // Return dummy data if API fails
      return _getDummyProducts(categoryId: categoryId, sellerId: sellerId);
    } catch (e) {
      print('Error getting products: $e');
      // Return dummy data on error
      return _getDummyProducts(categoryId: categoryId, sellerId: sellerId);
    }
  }

  List<ProductModel> _getDummyProducts({String? categoryId, String? sellerId}) {
    final allProducts = [
      // Produk untuk Beranda (semua user)
      ProductModel(
        id: '1',
        title: 'Kemeja Batik Pria',
        description: 'Kemeja batik berkualitas tinggi, kondisi 90%, jarang dipakai',
        price: 75000,
        imageUrl: 'https://via.placeholder.com/400x400/2D3FE3/FFFFFF?text=Kemeja+Batik',
        categoryId: '1',
        sellerId: '2',
        sellerName: 'Siti Aminah',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ProductModel(
        id: '2',
        title: 'Jeans Levi\'s Original',
        description: 'Celana jeans branded, kondisi masih bagus 85%',
        price: 150000,
        imageUrl: 'https://via.placeholder.com/400x400/2D3FE3/FFFFFF?text=Jeans+Levis',
        categoryId: '2',
        sellerId: '2',
        sellerName: 'Siti Aminah',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ProductModel(
        id: '3',
        title: 'Sepatu Nike Air Max',
        description: 'Sepatu olahraga Nike, masih layak pakai, ukuran 42',
        price: 200000,
        imageUrl: 'https://via.placeholder.com/400x400/2D3FE3/FFFFFF?text=Nike+Air',
        categoryId: '3',
        sellerId: '2',
        sellerName: 'Siti Aminah',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      ProductModel(
        id: '4',
        title: 'Tas Ransel Eiger',
        description: 'Tas ransel outdoor, kondisi 95%, baru beberapa kali pakai',
        price: 125000,
        imageUrl: 'https://via.placeholder.com/400x400/2D3FE3/FFFFFF?text=Tas+Eiger',
        categoryId: '4',
        sellerId: '3',
        sellerName: 'Budi Santoso',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      ProductModel(
        id: '5',
        title: 'Jam Tangan Casio',
        description: 'Jam tangan digital Casio, masih normal semua fungsi',
        price: 95000,
        imageUrl: 'https://via.placeholder.com/400x400/2D3FE3/FFFFFF?text=Casio',
        categoryId: '5',
        sellerId: '3',
        sellerName: 'Budi Santoso',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      ProductModel(
        id: '6',
        title: 'Kaos Polos Hitam',
        description: 'Kaos polos cotton combed, ukuran L, kondisi 90%',
        price: 35000,
        imageUrl: 'https://via.placeholder.com/400x400/2D3FE3/FFFFFF?text=Kaos+Polos',
        categoryId: '1',
        sellerId: '3',
        sellerName: 'Budi Santoso',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      // Produk khusus untuk Jualan Saya (user demo Warga - sellerId: '1')
      ProductModel(
        id: '101',
        title: 'Kaos Polos Putih Premium',
        description: 'Kaos polos premium, cotton combed 30s, ukuran M-XL',
        price: 45000,
        imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
        categoryId: '1',
        sellerId: '1',
        sellerName: 'Demo User',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ProductModel(
        id: '102',
        title: 'Jaket Denim Vintage',
        description: 'Jaket denim vintage style, kondisi 85%, warna pink',
        price: 175000,
        imageUrl: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400',
        categoryId: '1',
        sellerId: '1',
        sellerName: 'Demo User',
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ProductModel(
        id: '103',
        title: 'Topi Baseball Hitam',
        description: 'Topi baseball casual, bahan nyaman, one size fits all',
        price: 35000,
        imageUrl: 'https://images.unsplash.com/photo-1588850561407-ed78c282e89b?w=400',
        categoryId: '5',
        sellerId: '1',
        sellerName: 'Demo User',
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    var filtered = allProducts;
    if (categoryId != null) {
      filtered = filtered.where((p) => p.categoryId == categoryId).toList();
    }
    if (sellerId != null) {
      filtered = filtered.where((p) => p.sellerId == sellerId).toList();
    }
    return filtered;
  }

  // Add new product
  Future<Map<String, dynamic>> addProduct(ProductModel product) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.productsEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      ).timeout(ApiConfig.timeout);

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true, 'id': data['data']['id']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to add product'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  // Update product
  Future<Map<String, dynamic>> updateProduct(ProductModel product) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.productsEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      ).timeout(ApiConfig.timeout);

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to update product'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  // Delete product
  Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.productsEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': productId}),
      ).timeout(ApiConfig.timeout);

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to delete product'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }
}
