class Category {
  final String id;
  final String name;
  final String imageUrl;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }

  Category({this.id = '', required this.name, required this.imageUrl});
}
