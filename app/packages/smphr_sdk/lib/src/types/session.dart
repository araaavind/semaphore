import 'dart:convert';

import '../constants.dart';
import 'user.dart';

class Session {
  final String token;
  final String refreshToken;
  final DateTime refreshTokenExpiry;

  /// Returned when a login is confirmed.
  final DateTime expiry;

  final User? user;

  Session({
    required this.token,
    required this.expiry,
    required this.refreshToken,
    required this.refreshTokenExpiry,
    this.user,
  });

  /// Returns a `Session` object from a map of json response from the server
  /// returns `null` if there is no `token` or `refresh_token` present
  static Session? fromResponse(Map<String, dynamic> json) {
    // Access the nested maps for authentication and refresh tokens
    final authTokenData = json['authentication_token'] as Map<String, dynamic>?;
    final refreshTokenData = json['refresh_token'] as Map<String, dynamic>?;
    final userData = json['user'] as Map<String, dynamic>?;

    // Extract token and expiry strings from the nested maps
    final token = authTokenData?['token'] as String?;
    final expiryString = authTokenData?['expiry'] as String?;
    final refreshToken = refreshTokenData?['token'] as String?;
    final refreshTokenExpiryString = refreshTokenData?['expiry'] as String?;

    // Check if essential token information is present
    if (token == null ||
        expiryString == null ||
        refreshToken == null ||
        refreshTokenExpiryString == null) {
      return null;
    }

    return Session(
      token: token,
      expiry: DateTime.parse(expiryString),
      refreshToken: refreshToken,
      refreshTokenExpiry: DateTime.parse(refreshTokenExpiryString),
      // Pass the user map directly to User.fromJson
      user: userData != null ? User.fromMap(userData) : null,
    );
  }

  /// Returns a `Session` object from a map of json
  /// returns `null` if there is no `token` present
  static Session? fromMap(Map<String, dynamic> json) {
    // Check if all required fields are present
    if (json['token'] == null ||
        json['expiry'] == null ||
        json['refresh_token'] == null ||
        json['refresh_token_expiry'] == null) {
      return null;
    }

    return Session(
      token: json['token'] as String,
      expiry: DateTime.parse(json['expiry'] as String),
      refreshToken: json['refresh_token'] as String,
      refreshTokenExpiry:
          DateTime.parse(json['refresh_token_expiry'] as String),
      user: json['user'] != null ? User.fromJson(json['user'] as String) : null,
    );
  }

  static Session? fromJson(String source) =>
      Session.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expiry': expiry.toIso8601String(),
      'refresh_token': refreshToken,
      'refresh_token_expiry': refreshTokenExpiry.toIso8601String(),
      'user': user?.toJson(),
    };
  }

  /// Returns 'true` if the token is expired or will expire in the next 10 seconds.
  ///
  /// The 10 second buffer is to account for latency issues.
  bool get isExpired {
    return DateTime.now().add(Constants.expiryMargin).isAfter(expiry);
  }

  bool get isRefreshTokenExpired {
    return DateTime.now()
        .add(Constants.expiryMargin)
        .isAfter(refreshTokenExpiry);
  }

  Session copyWith({
    String? token,
    DateTime? expiry,
    String? refreshToken,
    DateTime? refreshTokenExpiry,
    User? user,
  }) {
    return Session(
      token: token ?? this.token,
      expiry: expiry ?? this.expiry,
      refreshToken: refreshToken ?? this.refreshToken,
      refreshTokenExpiry: refreshTokenExpiry ?? this.refreshTokenExpiry,
      user: user ?? this.user,
    );
  }

  @override
  String toString() {
    return 'Session(expiry: $expiry, user: $user, token: $token, refreshToken: $refreshToken, refreshTokenExpiry: $refreshTokenExpiry)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Session &&
        other.token == token &&
        other.expiry == expiry &&
        other.refreshToken == refreshToken &&
        other.refreshTokenExpiry == refreshTokenExpiry &&
        other.user == user;
  }

  @override
  int get hashCode {
    return token.hashCode ^
        expiry.hashCode ^
        refreshToken.hashCode ^
        refreshTokenExpiry.hashCode ^
        user.hashCode;
  }
}
