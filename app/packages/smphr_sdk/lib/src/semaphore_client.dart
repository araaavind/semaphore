import 'package:dio/dio.dart';

import 'auth_client.dart';
import 'interceptors/auth_interceptor.dart';
import 'local_storage.dart';

class SemaphoreClient {
  late final AuthClient auth;
  final Dio _dio;
  final LocalStorage _sharedLocalStorage;

  SemaphoreClient(Dio dio, LocalStorage sharedLocalStorage)
      : _dio = dio,
        _sharedLocalStorage = sharedLocalStorage {
    auth = AuthClient(
      dio: _dio,
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
    _dio.interceptors.add(AuthInterceptor(auth: auth));
  }
}
