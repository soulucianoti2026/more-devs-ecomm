class Category {
  final String name;
  final String imageUrl;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(name: json['name'], imageUrl: json['imageUrl']);
  }

  Category({required this.name, required this.imageUrl});
}
