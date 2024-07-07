import 'package:app/core/common/entities/user.dart';
import 'package:app/features/auth/domain/usecases/user_login.dart';
import 'package:app/features/auth/domain/usecases/user_signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignup _userSignup;
  final UserLogin _userLogin;

  AuthBloc({
    required UserSignup userSignup,
    required UserLogin userLogin,
  })  : _userSignup = userSignup,
        _userLogin = userLogin,
        super(AuthInitial()) {
    on<AuthSignupEvent>(_onAuthSignup);
    on<AuthLoginEvent>(_onAuthLogin);
  }

  void _onAuthSignup(AuthSignupEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userSignup(UserSignupParams(
      fullName: event.fullName,
      email: event.email,
      username: event.username,
      password: event.password,
    ));

    switch (res) {
      case Left(value: final l):
        emit(AuthFailure(l.message));
      case Right(value: final r):
        emit(AuthSuccess(r));
    }
  }

  void _onAuthLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userLogin(
      UserLoginParams(
        usernameOrEmail: event.usernameOrEmail,
        password: event.password,
      ),
    );

    switch (res) {
      case Left(value: final l):
        emit(AuthFailure(l.message));
      case Right(value: final r):
        emit(AuthSuccess(r));
    }
  }
}
