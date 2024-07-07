import 'dart:convert';

class ErrorResponse {
  final String message;
  final Map<String, String>? fieldErrors;
  ErrorResponse(
    this.message, {
    this.fieldErrors,
  });

  factory ErrorResponse.fromMap(Map<String, dynamic> map) {
    if (map['error'] != null) {
      if (map['error'] is String) {
        return ErrorResponse(map['error']);
      } else if (map['error'] is Map<String, dynamic>) {
        Map<String, String> fieldErrors = {};
        (map['error'] as Map<String, dynamic>).forEach((k, v) {
          fieldErrors[k] = v as String;
        });
        return ErrorResponse('Invalid fields', fieldErrors: fieldErrors);
      }
    }
    return ErrorResponse('Something went wrong.');
  }

  factory ErrorResponse.fromJson(String source) =>
      ErrorResponse.fromMap(json.decode(source) as Map<String, dynamic>);
}
