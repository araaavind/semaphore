import 'dart:async';

import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/common/entities/logout_scope.dart';
import 'package:app/core/common/entities/user.dart';
import 'package:app/core/constants/text_constants.dart';
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
import 'package:smphr_sdk/smphr_sdk.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUser _getCurrentUser;
  final CheckUsername _checkUsername;
  final UserSignup _userSignup;
  final UserLogin _userLogin;
  final UserLogout _userLogout;
  final AppUserCubit _appUserCubit;
  final SemaphoreClient _client;

  late StreamSubscription<AuthStatus> _authenticationStatusSubscription;

  AuthBloc({
    required GetCurrentUser getCurrentUser,
    required CheckUsername checkUsername,
    required UserSignup userSignup,
    required UserLogin userLogin,
    required UserLogout userLogout,
    required AppUserCubit appUserCubit,
    required SemaphoreClient client,
  })  : _getCurrentUser = getCurrentUser,
        _checkUsername = checkUsername,
        _userSignup = userSignup,
        _userLogin = userLogin,
        _userLogout = userLogout,
        _appUserCubit = appUserCubit,
        _client = client,
        super(AuthInitial()) {
    on<AuthCurrentUserRequested>(_onAuthCurrentUserRequested);
    on<AuthCheckUsernameRequested>(_onAuthCheckUsernameRequested);
    on<AuthSignupRequested>(_onAuthSignupRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);

    // Listen to auth status change events from sdk
    _authenticationStatusSubscription = _client.auth.status
        .listen((status) => add(AuthStatusChanged(status: status)));
  }

  @override
  Future<void> close() {
    _authenticationStatusSubscription.cancel();
    return super.close();
  }

  void _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.status == AuthStatus.unauthenticated) {
      emit(AuthInitial());
      _appUserCubit.clearUser();
    }
  }

  Future<void> _onAuthCurrentUserRequested(
    AuthCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _getCurrentUser(NoParams());
    switch (res) {
      case Left(value: _):
        _appUserCubit.clearUser();
        emit(AuthInitial());
      case Right(value: final r):
        _emitAuthSuccess(r, emit);
    }
  }

  Future<void> _onAuthCheckUsernameRequested(
    AuthCheckUsernameRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _checkUsername(CheckUsernameParams(event.username));
    switch (res) {
      case Left(value: final l):
        emit(AuthFailure(l.message));
      case Right(value: final r):
        if (r) {
          emit(AuthUsernameFailure(TextConstants.usernameTakenErrorMessage));
        } else {
          emit(AuthUsernameSuccess());
        }
    }
  }

  Future<void> _onAuthSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _userSignup(
      UserSignupParams(
        fullName: event.fullName,
        email: event.email,
        username: event.username,
        password: event.password,
      ),
    );

    switch (res) {
      case Left(value: final l):
        emit(AuthFailure(l.message));
      case Right(value: final _):
        emit(AuthSignupSuccess());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _userLogin(UserLoginParams(
      usernameOrEmail: event.usernameOrEmail,
      password: event.password,
    ));

    switch (res) {
      case Left(value: final l):
        emit(AuthFailure(l.message));
      case Right(value: final r):
        _emitAuthSuccess(r, emit);
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _userLogout(UserLogoutParams(scope: event.scope));

    switch (res) {
      case Left(value: final l):
        emit(AuthFailure(l.message));
      case Right(value: final _):
        if (event.scope != LogoutScope.others) {
          _appUserCubit.clearUser();
          emit(AuthInitial());
        } else {
          _emitAuthSuccess(event.user, emit);
        }
    }
  }

  void _emitAuthSuccess(User user, Emitter<AuthState> emit) {
    _appUserCubit.setUser(user);
    emit(AuthSuccess(user));
  }
}
