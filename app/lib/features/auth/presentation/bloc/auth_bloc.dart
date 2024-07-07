import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
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
  final AppUserCubit _appUserCubit;

  AuthBloc({
    required UserSignup userSignup,
    required UserLogin userLogin,
    required AppUserCubit appUserCubit,
  })  : _userSignup = userSignup,
        _userLogin = userLogin,
        _appUserCubit = appUserCubit,
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
        break;
      case Right(value: final r):
        _emitAuthSuccess(r, emit);
        break;
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
        break;
      case Right(value: final r):
        _emitAuthSuccess(r, emit);
        break;
    }
  }

  void _emitAuthSuccess(User user, Emitter<AuthState> emit) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }
}
