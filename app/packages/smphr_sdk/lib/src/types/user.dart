import 'dart:convert';

class User {
  final int id;
  final String email;
  final String username;
  final String? fullName;
  final DateTime? lastLoginAt;
  final bool isActivated;
  final String? profileImageURL;
  final bool? isAdmin;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.isActivated,
    this.fullName,
    this.lastLoginAt,
    this.profileImageURL,
    this.isAdmin,
  });

  User copyWith({
    int? id,
    String? email,
    String? username,
    String? fullName,
    DateTime? lastLoginAt,
    bool? isActivated,
    String? profileImageURL,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActivated: isActivated ?? this.isActivated,
      profileImageURL: profileImageURL ?? this.profileImageURL,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'activated': isActivated,
      'profile_image_url': profileImageURL,
      'is_admin': isAdmin,
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
      isAdmin: map['is_admin'] != null ? map['is_admin'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
