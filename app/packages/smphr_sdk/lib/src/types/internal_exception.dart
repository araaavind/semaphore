class InternalException implements Exception {
  final String message;
  final int? statusCode;
  const InternalException(this.message, {this.statusCode});
}
