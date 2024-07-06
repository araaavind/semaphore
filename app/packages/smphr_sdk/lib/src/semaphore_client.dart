import 'package:dio/dio.dart';

import 'auth_client.dart';
// import 'package:smphr_sdk/src/auth_client.dart';

class SemaphoreClient {
  late final AuthClient auth;

  SemaphoreClient(Dio dio) {
    auth = AuthClient(dio);
  }
}
