class Products {
  final String id;
  final String categoryId;
  final String description;
  final String brand;
  final String name;
  final String imageUrl;
  final double price;
  final String category;

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      description: json['description'] as String? ?? '',
      brand: json['brand'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
    );
  }

  Products({
    this.id = '',
    this.categoryId = '',
    this.description = '',
    required this.brand,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.category,
  });
}
