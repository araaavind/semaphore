import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  final String message;
  final Map<String, String>? fieldErrors;
  const Failure({
    this.message = 'An unexpected error occured',
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, fieldErrors];
}
