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
  final Map<String, String>? fieldErrors;
  AuthFailure(this.message, {this.fieldErrors});

  @override
  List<Object?> get props => [message, fieldErrors];
}

final class AuthSignupSuccess extends AuthState {}

final class AuthSignupFailure extends AuthFailure {
  AuthSignupFailure(super.message, {super.fieldErrors});
}

final class AuthUsernameSuccess extends AuthState {}

final class AuthUsernameFailure extends AuthFailure {
  AuthUsernameFailure(super.message, {super.fieldErrors});
}
