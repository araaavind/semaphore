part of 'activate_user_cubit.dart';

@immutable
sealed class ActivateUserState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class ActivateUserInitial extends ActivateUserState {}

final class ActivateUserSuccess extends ActivateUserState {}

final class ActivateUserLoading extends ActivateUserState {}

final class ActivateUserFailure extends ActivateUserState {
  final String message;

  ActivateUserFailure({required this.message});

  @override
  List<Object?> get props => super.props..addAll([message]);
}

final class SendActivationTokenSuccess extends ActivateUserState {
  final String message;

  SendActivationTokenSuccess({required this.message});

  @override
  List<Object?> get props => super.props..addAll([message]);
}
