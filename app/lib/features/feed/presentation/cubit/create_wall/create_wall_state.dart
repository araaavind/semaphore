part of 'create_wall_cubit.dart';

enum CreateWallStatus { initial, loading, success, failure }

class CreateWallState extends Equatable {
  final CreateWallStatus status;
  final String? message;
  final Map<String, String>? fieldErrors;

  const CreateWallState({
    required this.status,
    this.fieldErrors,
    this.message,
  });

  @override
  List<Object?> get props => [status, message, fieldErrors];

  CreateWallState copyWith({
    CreateWallStatus? status,
    String? message,
    Map<String, String>? fieldErrors,
  }) {
    return CreateWallState(
      status: status ?? this.status,
      message: message ?? this.message,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}
