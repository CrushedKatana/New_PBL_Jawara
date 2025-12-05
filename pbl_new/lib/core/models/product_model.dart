class ProductModel {
  final String id;
  final String title;
  final String? description;
  final double price;
  final String? categoryId;
  final String? categoryName;
  final String sellerId;
  final String? sellerName;
  final String? sellerPhone;
  final String? imageUrl;
  final String? location;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.categoryId,
    this.categoryName,
    required this.sellerId,
    this.sellerName,
    this.sellerPhone,
    this.imageUrl,
    this.location,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      price: double.parse(json['price']?.toString() ?? '0'),
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      sellerId: json['seller_id'] ?? '',
      sellerName: json['seller_name'],
      sellerPhone: json['seller_phone'],
      imageUrl: json['image_url'],
      location: json['location'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category_id': categoryId,
      'seller_id': sellerId,
      'image_url': imageUrl,
      'location': location,
    };
  }
}
