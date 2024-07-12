class ErrorResponse {
  final String message;
  final Map<String, String>? fieldErrors;
  ErrorResponse(
    this.message, {
    this.fieldErrors,
  });
}
