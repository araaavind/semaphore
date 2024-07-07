part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthSignupEvent extends AuthEvent {
  final String fullName;
  final String email;
  final String username;
  final String password;

  AuthSignupEvent({
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
  });
}

final class AuthLoginEvent extends AuthEvent {
  final String usernameOrEmail;
  final String password;

  AuthLoginEvent({
    required this.usernameOrEmail,
    required this.password,
  });
}
