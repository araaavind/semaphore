import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String username;
  final String? fullName;

  const User({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
  });

  @override
  List<Object?> get props => [id, email, username, fullName];
}
