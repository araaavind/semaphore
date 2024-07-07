import 'dart:convert';

import '../constants.dart';
import 'user.dart';

class Session {
  final String token;

  /// Returned when a login is confirmed.
  final DateTime expiry;

  final String? tokenType;
  final User? user;

  Session({
    required this.token,
    required this.expiry,
    this.tokenType,
    this.user,
  });

  /// Returns a `Session` object from a map of json
  /// returns `null` if there is no `token` present
  static Session? fromMap(Map<String, dynamic> json) {
    if (json['token'] == null) {
      return null;
    }
    return Session(
      token: json['token'] as String,
      expiry: DateTime.parse(json['expiry'] as String),
      tokenType:
          json['token_type'] != null ? json['token_type'] as String : null,
      user: json['user'] != null ? User.fromJson(json['user'] as String) : null,
    );
  }

  static Session? fromJson(String source) =>
      Session.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expiry': expiry.toLocal().toIso8601String(),
      'token_type': tokenType,
      'user': user?.toJson(),
    };
  }

  /// Returns 'true` if the token is expired or will expire in the next 10 seconds.
  ///
  /// The 10 second buffer is to account for latency issues.
  bool get isExpired {
    return DateTime.now().add(Constants.expiryMargin).isAfter(expiry);
  }

  Session copyWith({
    String? token,
    DateTime? expiry,
    String? refreshToken,
    String? tokenType,
    String? providerToken,
    String? providerRefreshToken,
    User? user,
  }) {
    return Session(
      token: token ?? this.token,
      expiry: expiry ?? this.expiry,
      tokenType: tokenType ?? this.tokenType,
      user: user ?? this.user,
    );
  }

  @override
  String toString() {
    return 'Session(expiry: $expiry, tokenType: $tokenType, user: $user, token: $token)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Session &&
        other.token == token &&
        other.expiry == expiry &&
        other.tokenType == tokenType &&
        other.user == user;
  }

  @override
  int get hashCode {
    return token.hashCode ^
        expiry.hashCode ^
        tokenType.hashCode ^
        user.hashCode;
  }
}
