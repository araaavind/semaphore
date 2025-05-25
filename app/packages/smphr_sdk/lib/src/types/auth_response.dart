import 'dart:convert';

import 'session.dart';
import 'user.dart';

class AuthResponse {
  final Session? session;
  final User? user;
  final bool isNewUser;

  AuthResponse({
    this.session,
    this.user,
    this.isNewUser = false,
  });

  factory AuthResponse.fromMap(Map<String, dynamic> map) {
    User? user = map['user'] != null
        ? User.fromMap(map['user'] as Map<String, dynamic>)
        : null;
    final isAdmin = map['is_admin'] as bool? ?? null;
    user = user?.copyWith(isAdmin: isAdmin);
    final session = Session.fromResponse(map);
    return AuthResponse(
      session: session,
      user: user,
      isNewUser: map['is_new_user'] ?? false,
    );
  }

  factory AuthResponse.fromJson(String source) =>
      AuthResponse.fromMap(json.decode(source) as Map<String, dynamic>);
}
