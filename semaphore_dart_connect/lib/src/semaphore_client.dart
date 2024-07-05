import 'package:dio/dio.dart';

class SemaphoreClient {
  final Dio dio;
  final String baseUrl;

  SemaphoreClient(
    this.dio, {
    required this.baseUrl,
  });
}
