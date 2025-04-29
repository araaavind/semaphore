import 'package:app/features/auth/domain/usecases/resetPassword.dart';
import 'package:app/features/auth/domain/usecases/send_password_reset_token.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final ResetPassword _resetPassword;
  final SendPasswordResetToken _sendPasswordResetToken;
  ResetPasswordCubit({
    required ResetPassword resetPassword,
    required SendPasswordResetToken sendPasswordResetToken,
  })  : _resetPassword = resetPassword,
        _sendPasswordResetToken = sendPasswordResetToken,
        super(ResetPasswordInitial());

  Future<void> resetPassword(String token, String password) async {
    emit(ResetPasswordLoading());
    final res = await _resetPassword(
      ResetPasswordParams(token: token, password: password),
    );

    switch (res) {
      case Left(value: final l):
        emit(ResetPasswordFailure(
          message: l.message,
          fieldErrors: l.fieldErrors,
        ));
      case Right(value: final _):
        emit(ResetPasswordSuccess());
    }
  }

  Future<void> sendPasswordResetToken(String email) async {
    emit(ResetPasswordLoading());
    final res = await _sendPasswordResetToken(email);

    switch (res) {
      case Left(value: final l):
        emit(ResetPasswordFailure(
          message: l.message,
          fieldErrors: l.fieldErrors,
        ));
      case Right(value: final r):
        emit(SendPasswordResetTokenSuccess(message: r));
    }
  }
}
