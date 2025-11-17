import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/product_model.dart';

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
      return [];
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
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
