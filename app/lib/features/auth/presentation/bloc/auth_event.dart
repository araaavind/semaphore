part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent extends Equatable {}

final class AuthSignupRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String username;
  final String password;

  AuthSignupRequested({
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, email, username, password];
}

final class AuthLoginRequested extends AuthEvent {
  final String usernameOrEmail;
  final String password;

  AuthLoginRequested({
    required this.usernameOrEmail,
    required this.password,
  });

  @override
  List<Object?> get props => [usernameOrEmail, password];
}

final class AuthCurrentUserRequested extends AuthEvent {
  @override
  List<Object?> get props => [];
}

final class AuthCheckUsernameRequested extends AuthEvent {
  final String username;

  AuthCheckUsernameRequested(this.username);

  @override
  List<Object?> get props => [];
}

final class AuthLogoutRequested extends AuthEvent {
  final LogoutScope scope;
  final User user;

  AuthLogoutRequested({
    required this.user,
    this.scope = LogoutScope.local,
  });

  @override
  List<Object?> get props => [user, scope];
}

final class AuthStatusChanged extends AuthEvent {
  final sp.AuthStatus status;

  AuthStatusChanged({required this.status});

  @override
  List<Object?> get props => [status];
}

final class AuthGoogleLoginRequested extends AuthEvent {
  AuthGoogleLoginRequested();

  @override
  List<Object?> get props => [];
}

final class AuthUpdateUsernameRequested extends AuthEvent {
  final String username;

  AuthUpdateUsernameRequested(this.username);

  @override
  List<Object?> get props => [username];
}
