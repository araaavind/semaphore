part of 'reset_password_cubit.dart';

@immutable
sealed class ResetPasswordState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class ResetPasswordInitial extends ResetPasswordState {
  final String? message;
  final Map<String, String>? fieldErrors;

  ResetPasswordInitial({this.message, this.fieldErrors});

  @override
  List<Object?> get props => super.props..addAll([message, fieldErrors]);
}

final class ResetPasswordSuccess extends ResetPasswordState {}

final class ResetPasswordLoading extends ResetPasswordState {}

final class ResetPasswordFailure extends ResetPasswordState {
  final String message;
  final Map<String, String>? fieldErrors;

  ResetPasswordFailure({required this.message, this.fieldErrors});

  @override
  List<Object?> get props => super.props..addAll([message, fieldErrors]);
}

final class SendPasswordResetTokenSuccess extends ResetPasswordState {
  final String message;

  SendPasswordResetTokenSuccess({required this.message});

  @override
  List<Object?> get props => super.props..addAll([message]);
}
