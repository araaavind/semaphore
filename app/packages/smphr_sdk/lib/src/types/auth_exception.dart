import 'semaphore_exception.dart';

class AuthException extends SemaphoreException {
  const AuthException(super.message, {super.statusCode});

  @override
  String toString() =>
      'AuthException(message: $message, statusCode: $statusCode)';
}

class SessionExpiredException extends SemaphoreException {
  SessionExpiredException(super.message);
}
