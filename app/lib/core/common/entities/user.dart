import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String username;
  final String? fullName;
  final DateTime? lastLoginAt;
  final bool isActivated;
  final String? profileImageURL;
  final bool? isAdmin;

  const User({
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

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        fullName,
        lastLoginAt,
        isActivated,
        profileImageURL,
        isAdmin,
      ];
}
