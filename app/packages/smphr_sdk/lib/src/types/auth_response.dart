import 'dart:convert';

import 'auth_token.dart';
import 'user.dart';

class AuthResponse {
  final AuthToken? authToken;
  final User? user;

  AuthResponse({
    this.authToken,
    this.user,
  });

  factory AuthResponse.fromMap(Map<String, dynamic> map) {
    return AuthResponse(
      authToken: map['authentication_token'] != null
          ? AuthToken.fromMap(
              map['authentication_token'] as Map<String, dynamic>)
          : null,
      user: map['user'] != null
          ? User.fromMap(map['user'] as Map<String, dynamic>)
          : null,
    );
  }

  factory AuthResponse.fromJson(String source) =>
      AuthResponse.fromMap(json.decode(source) as Map<String, dynamic>);
}
