class SemaphoreException implements Exception {
  final String message;
  final int? statusCode;
  const SemaphoreException(this.message, {this.statusCode});
}
