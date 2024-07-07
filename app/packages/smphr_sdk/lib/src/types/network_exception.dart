import 'package:dio/dio.dart';

class NetworkException extends DioException {
  NetworkException({
    super.message,
    required super.requestOptions,
  });
}
