import 'package:app/features/auth/domain/usecases/activate_user.dart';
import 'package:app/features/auth/domain/usecases/send_activation_token.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'activate_user_state.dart';

class ActivateUserCubit extends Cubit<ActivateUserState> {
  final ActivateUser _activateUser;
  final SendActivationToken _sendActivationToken;
  ActivateUserCubit({
    required ActivateUser activateUser,
    required SendActivationToken sendActivationToken,
  })  : _activateUser = activateUser,
        _sendActivationToken = sendActivationToken,
        super(ActivateUserInitial());

  Future<void> activateUser(String token) async {
    emit(ActivateUserLoading());
    final res = await _activateUser(token);

    switch (res) {
      case Left(value: final l):
        emit(ActivateUserFailure(message: l.message));
      case Right(value: final _):
        emit(ActivateUserSuccess());
    }
  }

  Future<void> sendActivationToken(String email) async {
    final res = await _sendActivationToken(email);

    switch (res) {
      case Left(value: final l):
        emit(ActivateUserFailure(message: l.message));
      case Right(value: final r):
        emit(SendActivationTokenSuccess(message: r));
    }
  }
}
