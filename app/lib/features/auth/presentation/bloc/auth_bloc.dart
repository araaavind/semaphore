import 'dart:async';

import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/common/entities/logout_scope.dart';
import 'package:app/core/common/entities/user.dart';
import 'package:app/core/constants/text_constants.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/auth/domain/usecases/check_username.dart';
import 'package:app/features/auth/domain/usecases/get_current_user.dart';
import 'package:app/features/auth/domain/usecases/login_with_google.dart';
import 'package:app/features/auth/domain/usecases/update_username.dart';
import 'package:app/features/auth/domain/usecases/user_login.dart';
import 'package:app/features/auth/domain/usecases/user_logout.dart';
import 'package:app/features/auth/domain/usecases/user_signup.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smphr_sdk/smphr_sdk.dart' as sp;

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUser _getCurrentUser;
  final CheckUsername _checkUsername;
  final UpdateUsername _updateUsername;
  final UserSignup _userSignup;
  final UserLogin _userLogin;
  final UserLogout _userLogout;
  final LoginWithGoogle _loginWithGoogle;
  final AppUserCubit _appUserCubit;
  final sp.SemaphoreClient _client;

  late StreamSubscription<sp.AuthStatus> _authenticationStatusSubscription;

  AuthBloc({
    required GetCurrentUser getCurrentUser,
    required CheckUsername checkUsername,
    required UpdateUsername updateUsername,
    required UserSignup userSignup,
    required UserLogin userLogin,
    required UserLogout userLogout,
    required LoginWithGoogle loginWithGoogle,
    required AppUserCubit appUserCubit,
    required sp.SemaphoreClient client,
  })  : _getCurrentUser = getCurrentUser,
        _checkUsername = checkUsername,
        _updateUsername = updateUsername,
        _userSignup = userSignup,
        _userLogin = userLogin,
        _userLogout = userLogout,
        _loginWithGoogle = loginWithGoogle,
        _appUserCubit = appUserCubit,
        _client = client,
        super(AuthInitial()) {
    on<AuthCurrentUserRequested>(_onAuthCurrentUserRequested);
    on<AuthCheckUsernameRequested>(_onAuthCheckUsernameRequested);
    on<AuthUpdateUsernameRequested>(_onUpdateUsernameRequested);
    on<AuthSignupRequested>(_onAuthSignupRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<AuthGoogleLoginRequested>(_onAuthGoogleLoginRequested);

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
    if (event.status == sp.AuthStatus.unauthenticated && state is AuthSuccess) {
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
        _emitAuthSuccess(r, false, emit);
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
        emit(AuthUsernameFailure(l.message));
      case Right(value: final r):
        if (r) {
          emit(
            AuthUsernameFailure(
              TextConstants.usernameTakenErrorMessage,
              fieldErrors: const {
                'username': TextConstants.usernameTakenErrorMessage
              },
            ),
          );
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
        emit(AuthSignupFailure(l.message, fieldErrors: l.fieldErrors));
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
        emit(AuthLoginFailure(l.message, fieldErrors: l.fieldErrors));
      case Right(value: final r):
        _emitAuthSuccess(r, false, emit);
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
          _emitAuthSuccess(event.user, false, emit);
        }
    }
  }

  Future<void> _onAuthGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _loginWithGoogle();

    switch (res) {
      case Left(value: final l):
        emit(AuthLoginFailure(l.message));
      case Right(value: final r):
        _emitAuthSuccess(r.user, r.isNewUser, emit);
    }
  }

  Future<void> _onUpdateUsernameRequested(
    AuthUpdateUsernameRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _updateUsername(event.username);

    switch (res) {
      case Left(value: final l):
        emit(AuthUpdateUsernameFailure(l.message, fieldErrors: l.fieldErrors));
      case Right(value: final _):
        if (_appUserCubit.state is AppUserLoggedIn) {
          final currentUser = (_appUserCubit.state as AppUserLoggedIn).user;
          _appUserCubit.setUser(currentUser.copyWith(username: event.username));
        }
        emit(AuthUpdateUsernameSuccess());
    }
  }

  void _emitAuthSuccess(
    User user,
    bool isNewUser,
    Emitter<AuthState> emit,
  ) {
    _appUserCubit.setUser(user);
    emit(AuthSuccess(user, isNewUser: isNewUser));
  }
}
