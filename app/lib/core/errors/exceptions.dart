import 'package:equatable/equatable.dart';

class ServerException extends Equatable implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;
  const ServerException(this.message, {this.fieldErrors});

  @override
  List<Object?> get props => [message, fieldErrors];
}
