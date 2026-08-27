class Products {
  final String brand;
  final String name;
  final String imageUrl;
  final double price;

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      brand: json['brand'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      price: json['price'],
    );
  }

  Products({
    required this.brand,
    required this.name,
    required this.imageUrl,
    required this.price,
  });
}
