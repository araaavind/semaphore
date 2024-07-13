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

final class AuthCurrentUserEvent extends AuthEvent {}

final class AuthCheckUsernameEvent extends AuthEvent {
  final String username;

  AuthCheckUsernameEvent(this.username);
}

final class AuthLogoutEvent extends AuthEvent {
  final LogoutScope scope;
  final User user;

  AuthLogoutEvent({
    required this.user,
    this.scope = LogoutScope.local,
  });
}

final class AuthStatusChangeEvent extends AuthEvent {
  final AuthStatus status;

  AuthStatusChangeEvent({required this.status});
}
