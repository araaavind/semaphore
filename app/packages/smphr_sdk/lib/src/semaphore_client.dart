import 'package:dio/dio.dart';
import 'package:smphr_sdk/src/interceptors/error_interceptor.dart';

import 'auth_client.dart';
import 'interceptors/auth_interceptor.dart';
import 'local_storage.dart';

class SemaphoreClient {
  late final AuthClient auth;
  final Dio dio;
  final LocalStorage _sharedLocalStorage;

  SemaphoreClient(this.dio, LocalStorage sharedLocalStorage)
      : _sharedLocalStorage = sharedLocalStorage {
    auth = AuthClient(
      dio: dio,
      sharedLocalStorage: _sharedLocalStorage,
    );
  }

  Future<void> initialize() async {
    final hasSession = await _sharedLocalStorage.hasSession();
    if (hasSession) {
      final session = await _sharedLocalStorage.getSession();
      if (session != null) {
        // use try catch when signout is implemented in setInitialSession when session does not exist
        auth.setInitialSession(session);
      }
    }
    dio.interceptors.add(AuthInterceptor(auth: auth));
    dio.interceptors.add(ErrorInterceptor(auth: auth));
  }
}
