import 'package:equatable/equatable.dart';

class ErrorResponse extends Equatable {
  final String message;
  final Map<String, String>? fieldErrors;
  const ErrorResponse(
    this.message, {
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, fieldErrors];
}
