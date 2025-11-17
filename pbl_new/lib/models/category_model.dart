class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.productCount,
  });

  static List<CategoryModel> getCategories() {
    return [
      CategoryModel(
        id: 't-shirt',
        name: 'T-Shirt',
        icon: '👕',
        productCount: 124,
      ),
      CategoryModel(
        id: 'kemeja',
        name: 'Kemeja',
        icon: '📦',
        productCount: 89,
      ),
      CategoryModel(
        id: 'topi',
        name: 'Topi',
        icon: '⚪',
        productCount: 45,
      ),
      CategoryModel(
        id: 'sepatu',
        name: 'Sepatu',
        icon: '👟',
        productCount: 67,
      ),
      CategoryModel(
        id: 'jaket',
        name: 'Jaket',
        icon: '🧥',
        productCount: 52,
      ),
    ];
  }
}
