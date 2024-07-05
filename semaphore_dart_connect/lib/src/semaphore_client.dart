import 'package:dio/dio.dart';
import 'package:semaphore_dart_connect/src/auth_client.dart';

class SemaphoreClient {
  late final AuthClient auth;

  SemaphoreClient(Dio dio) {
    auth = AuthClient(dio);
  }
}
