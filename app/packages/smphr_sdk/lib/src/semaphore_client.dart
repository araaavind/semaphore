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

  /// Constructs a [SemaphoreClient].
  ///
  /// Initializes the [AuthClient] with the provided [dio] instance and
  /// [sharedLocalStorage].
  SemaphoreClient(this.dio, LocalStorage sharedLocalStorage)
      : _sharedLocalStorage = sharedLocalStorage {
    auth = AuthClient(
      dio: dio,
      sharedLocalStorage: _sharedLocalStorage,
    );
  }

  // Stream controller for broadcasting network status changes.
  final _networkStreamController = StreamController<NetworkStatus>();

  /// A stream that emits the current network status.
  ///
  /// It initially yields [NetworkStatus.connected] and then emits updates
  /// based on the network connection changes detected by the listener.
  Stream<NetworkStatus> get networkStatus async* {
    yield NetworkStatus.connected;
    yield* _networkStreamController.stream;
  }

  // Subscription to the internet connection status changes.
  late final StreamSubscription<InternetStatus> _networkStatusListener;

  /// Initializes the listener for network status changes.
  ///
  /// Listens to [InternetConnection().onStatusChange] and updates the
  /// [_networkStreamController] accordingly.
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

  /// Initializes the [SemaphoreClient].
  ///
  /// This method should be called before using the client. It performs the
  /// following actions:
  /// 1. Initializes the network status listener.
  /// 2. Loads any existing session from local storage and sets it in the [AuthClient].
  /// 3. Registers necessary Dio interceptors ([AuthInterceptor], [ErrorInterceptor]).
  Future<void> initialize() async {
    // Initialize network listener
    initializeNetworkListener();

    // Set initial session if available in local storage
    final hasSession = await _sharedLocalStorage.hasSession();
    if (hasSession) {
      final session = await _sharedLocalStorage.getSession();
      // Check if session is not null as having a key does not guarantee that
      // there is a non null value
      if (session != null) {
        auth.setInitialSession(session);
      }
    }

    // Register the interceptors for handling auth and errors
    dio.interceptors.add(AuthInterceptor(auth: auth));
    dio.interceptors.add(ErrorInterceptor(auth: auth));
  }

  /// Cleans up resources used by the client.
  ///
  /// This should be called when the client is no longer needed to prevent
  /// memory leaks. It cancels the network status listener, closes the stream
  /// controller, and disposes the [AuthClient].
  void dispose() {
    _networkStatusListener.cancel();
    _networkStreamController.close();
    auth.dispose();
  }
}
