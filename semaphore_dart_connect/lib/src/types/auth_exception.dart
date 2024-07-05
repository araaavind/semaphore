import 'package:semaphore_dart_connect/src/types/semaphore_exception.dart';

class AuthException extends SemaphoreException {
  const AuthException(super.message, {super.statusCode});

  @override
  String toString() =>
      'AuthException(message: $message, statusCode: $statusCode)';
}
