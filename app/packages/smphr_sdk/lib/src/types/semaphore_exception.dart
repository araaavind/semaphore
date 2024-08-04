import 'package:dio/dio.dart';

enum SemaphoreExceptionSubType {
  unknown,
  invalidField,
  none,
  notFound,
  unauthorized,
  forbidden,
  sessionExpired,
  connectionFailed,
}

class SemaphoreException extends DioException {
  final SemaphoreExceptionSubType subType;
  final int? responseStatusCode;
  final Map<String, String>? fieldErrors;
  SemaphoreException({
    required this.subType,
    this.responseStatusCode,
    this.fieldErrors,
    required super.message,
    required super.type,
    required super.requestOptions,
  });
}
