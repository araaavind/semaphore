import 'dart:convert';

class User {
  final int id;
  final String email;
  final String username;
  final String? fullName;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      email: map['email'] as String,
      username: map['username'] as String,
      fullName: map['full_name'] != null ? map['full_name'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
