import 'dart:async';

import 'package:dio/dio.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:smphr_sdk/src/interceptors/error_interceptor.dart';

import 'auth_client.dart';
import 'interceptors/auth_interceptor.dart';
import 'local_storage.dart';

enum NetworkStatus { connected, disconnected }

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

  final _networkStreamController = StreamController<NetworkStatus>();
  Stream<NetworkStatus> get networkStatus async* {
    yield NetworkStatus.connected;
    yield* _networkStreamController.stream;
  }

  late final StreamSubscription<InternetStatus> _networkStatusListener;
  void initializeNetworkListener() {
    _networkStatusListener = InternetConnection().onStatusChange.listen(
      (InternetStatus status) {
        switch (status) {
          case InternetStatus.connected:
            _networkStreamController.add(NetworkStatus.connected);
          case InternetStatus.disconnected:
            _networkStreamController.add(NetworkStatus.disconnected);
        }
      },
    );
  }

  Future<void> initialize() async {
    // Initialize network listener
    initializeNetworkListener();

    // Set initial session
    final hasSession = await _sharedLocalStorage.hasSession();
    if (hasSession) {
      final session = await _sharedLocalStorage.getSession();
      // Check if session is not null as having a key does not guarantee that
      // there is a non null value
      if (session != null) {
        auth.setInitialSession(session);
      }
    }

    // Register the interceptors
    dio.interceptors.add(AuthInterceptor(auth: auth));
    dio.interceptors.add(ErrorInterceptor(auth: auth));
  }

  void dispose() {
    _networkStatusListener.cancel();
    _networkStreamController.close();
    auth.dispose();
  }
}
