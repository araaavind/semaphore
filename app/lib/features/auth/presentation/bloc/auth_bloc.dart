import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/common/entities/user.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/auth/domain/usecases/check_username.dart';
import 'package:app/features/auth/domain/usecases/get_current_user.dart';
import 'package:app/features/auth/domain/usecases/user_login.dart';
import 'package:app/features/auth/domain/usecases/user_logout.dart';
import 'package:app/features/auth/domain/usecases/user_signup.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUser _getCurrentUser;
  final CheckUsername _checkUsername;
  final UserSignup _userSignup;
  final UserLogin _userLogin;
  final UserLogout _userLogout;
  final AppUserCubit _appUserCubit;

  AuthBloc({
    required GetCurrentUser getCurrentUser,
    required CheckUsername checkUsername,
    required UserSignup userSignup,
    required UserLogin userLogin,
    required UserLogout userLogout,
    required AppUserCubit appUserCubit,
  })  : _getCurrentUser = getCurrentUser,
        _checkUsername = checkUsername,
        _userSignup = userSignup,
        _userLogin = userLogin,
        _userLogout = userLogout,
        _appUserCubit = appUserCubit,
        super(AuthInitial()) {
    on<AuthCurrentUserEvent>(_onAuthCurrentUser);
    on<AuthCheckUsernameEvent>(_onAuthCheckUsername);
    on<AuthSignupEvent>(_onAuthSignup);
    on<AuthLoginEvent>(_onAuthLogin);
    on<AuthLogoutEvent>(_onAuthLogout);
  }

  void _onAuthCurrentUser(
    AuthCurrentUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _getCurrentUser(NoParams());
    switch (res) {
      case Left(value: _):
        emit(AuthInitial());
        break;
      case Right(value: final r):
        _emitAuthSuccess(r, emit);
        break;
    }
  }

  void _onAuthCheckUsername(
    AuthCheckUsernameEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _checkUsername(CheckUsernameParams(event.username));
    switch (res) {
      case Left(value: final l):
        emit(AuthFailure(l.message));
        break;
      case Right(value: final r):
        if (r) {
          emit(AuthUsernameFailure('Username is already taken'));
        } else {
          emit(AuthUsernameSuccess());
        }
        break;
    }
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

  void _onAuthLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userLogout(UserLogoutParams(scope: event.scope));

    switch (res) {
      case Left(value: final l):
        emit(AuthFailure(l.message));
        break;
      case Right(value: final _):
        if (event.scope != LogoutScope.others) {
          _appUserCubit.updateUser(null);
          emit(AuthInitial());
        } else {
          emit(AuthSuccess(event.user));
        }
        break;
    }
  }

  void _emitAuthSuccess(User user, Emitter<AuthState> emit) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }
}
