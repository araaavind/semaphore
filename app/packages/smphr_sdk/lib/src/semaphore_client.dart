import 'package:dio/dio.dart';

import 'auth_client.dart';
import 'local_storage.dart';

class SemaphoreClient {
  late final AuthClient auth;
  final LocalStorage _sharedLocalStorage;

  SemaphoreClient(Dio dio, LocalStorage sharedLocalStorage)
      : _sharedLocalStorage = sharedLocalStorage {
    auth = AuthClient(dio);
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
  }
}
