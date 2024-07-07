import 'dart:convert';

import 'session.dart';
import 'user.dart';

class AuthResponse {
  final Session? session;
  final User? user;

  AuthResponse({
    this.session,
    this.user,
  });

  factory AuthResponse.fromMap(Map<String, dynamic> map) {
    final user = map['user'] != null
        ? User.fromMap(map['user'] as Map<String, dynamic>)
        : null;
    final session = map['authentication_token'] != null
        ? Session.fromMap(map['authentication_token'] as Map<String, dynamic>)
        : null;
    return AuthResponse(
      session: session?.copyWith(user: user),
      user: user,
    );
  }

  factory AuthResponse.fromJson(String source) =>
      AuthResponse.fromMap(json.decode(source) as Map<String, dynamic>);
}
