part of 'wall_cubit.dart';

enum WallStatus { initial, loading, success, failure }

enum WallAction { create, update, delete, pin, unpin }

class WallState extends Equatable {
  final WallStatus status;
  final WallAction? action;
  final String? message;
  final Map<String, String>? fieldErrors;

  const WallState({
    required this.status,
    this.action,
    this.fieldErrors,
    this.message,
  });

  @override
  List<Object?> get props => [status, action, message, fieldErrors];

  WallState copyWith({
    WallStatus? status,
    WallAction? action,
    String? message,
    Map<String, String>? fieldErrors,
  }) {
    return WallState(
      status: status ?? this.status,
      action: action ?? this.action,
      message: message ?? this.message,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}
