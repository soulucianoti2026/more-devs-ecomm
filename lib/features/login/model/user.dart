class User {
  final String id;
  final DateTime? createdAt;
  final String nome;
  final String email;

  User({this.id = '', this.createdAt, required this.nome, required this.email});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    nome: json['name'] as String,
    email: json['email'] as String,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
  );
}
