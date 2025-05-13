import 'dart:convert';

class User {
  final int id;
  final String email;
  final String username;
  final String? fullName;
  final DateTime? lastLoginAt;
  final bool isActivated;
  final String? profileImageURL;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.isActivated,
    this.fullName,
    this.lastLoginAt,
    this.profileImageURL,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'is_activated': isActivated,
      'profile_image_url': profileImageURL,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      email: map['email'] as String,
      username: map['username'] as String,
      fullName: map['full_name'] != null ? map['full_name'] as String : null,
      lastLoginAt: map['last_login_at'] != null
          ? DateTime.parse(map['last_login_at'] as String)
          : null,
      isActivated: map['activated'] != null ? map['activated'] as bool : false,
      profileImageURL: map['profile_image_url'] != null
          ? map['profile_image_url'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
