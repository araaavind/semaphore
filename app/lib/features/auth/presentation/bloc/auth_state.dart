part of 'auth_bloc.dart';

@immutable
sealed class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final User user;

  AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

final class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

final class AuthUsernameSuccess extends AuthState {}

final class AuthUsernameFailure extends AuthState {
  final String message;
  AuthUsernameFailure(this.message);

  @override
  List<Object?> get props => super.props..add(message);
}
