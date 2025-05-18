import 'dart:convert';

import 'package:app/core/common/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.isActivated,
    super.fullName,
    super.lastLoginAt,
    super.profileImageURL,
  });

  @override
  User copyWith({
    int? id,
    String? email,
    String? username,
    String? fullName,
    DateTime? lastLoginAt,
    bool? isActivated,
    String? profileImageURL,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActivated: isActivated ?? this.isActivated,
      profileImageURL: profileImageURL ?? this.profileImageURL,
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
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      email: map['email'] ?? '',
      username: map['username'] as String,
      fullName: map['full_name'] ?? '',
      lastLoginAt: map['last_login_at'] != null
          ? DateTime.parse(map['last_login_at'] as String)
          : null,
      isActivated: map['activated'] != null ? map['activated'] as bool : false,
      profileImageURL: map['profile_image_url'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
