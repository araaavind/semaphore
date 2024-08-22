part of 'create_wall_cubit.dart';

enum CreateWallStatus { initial, loading, success, failure }

class CreateWallState extends Equatable {
  final CreateWallStatus status;
  final String? message;

  const CreateWallState({
    required this.status,
    this.message,
  });

  @override
  List<Object?> get props => [status, message];

  CreateWallState copyWith({
    CreateWallStatus? status,
    String? message,
  }) {
    return CreateWallState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
