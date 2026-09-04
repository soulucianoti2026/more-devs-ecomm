class Products {
  final String brand;
  final String name;
  final String imageUrl;
  final double price;
  final String category;

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      brand: json['brand'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      price: json['price'],
      category: json['category'],
    );
  }

  Products({
    required this.brand,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.category,
  });
}
