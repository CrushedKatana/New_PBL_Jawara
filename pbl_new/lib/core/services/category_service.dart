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
      // Return dummy data if API fails
      return _getDummyCategories();
    } catch (e) {
      print('Error getting categories: $e');
      // Return dummy data on error
      return _getDummyCategories();
    }
  }

  List<CategoryModel> _getDummyCategories() {
    return [
      CategoryModel(
        id: '1',
        name: 'Baju',
        icon: '👕',
      ),
      CategoryModel(
        id: '2',
        name: 'Celana',
        icon: '👖',
      ),
      CategoryModel(
        id: '3',
        name: 'Sepatu',
        icon: '👟',
      ),
      CategoryModel(
        id: '4',
        name: 'Tas',
        icon: '👜',
      ),
      CategoryModel(
        id: '5',
        name: 'Aksesoris',
        icon: '⌚',
      ),
    ];
  }
}
