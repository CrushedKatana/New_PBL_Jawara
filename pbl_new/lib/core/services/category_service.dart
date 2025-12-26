import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pbl_new/config/api_config.dart';
import 'package:pbl_new/core/models/category_model.dart';

class CategoryService {
  // Get all categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.categoriesEndpoint),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<CategoryModel> categories = [];
          for (var item in data['data']) {
            categories.add(CategoryModel.fromJson(item));
          }
          return categories;
        }
      }
      return [];
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }
}
