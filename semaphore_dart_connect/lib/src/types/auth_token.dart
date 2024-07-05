import 'dart:convert';

class AuthToken {
  final String token;
  final DateTime expiry;

  AuthToken({
    required this.token,
    required this.expiry,
  });

  factory AuthToken.fromMap(Map<String, dynamic> map) {
    return AuthToken(
      token: map['token'] as String,
      expiry: DateTime.parse(map['expiry'] as String),
    );
  }

  factory AuthToken.fromJson(String source) =>
      AuthToken.fromMap(json.decode(source) as Map<String, dynamic>);
}
