import 'package:dio/dio.dart';

import 'constants.dart';
import 'local_storage.dart';
import 'semaphore_client.dart';

/// A singleton class providing access to the Semaphore SDK functionality.
class Semaphore {
  // Private constructor for the singleton pattern.
  Semaphore._();
  // The single instance of the Semaphore class.
  static final Semaphore _instance = Semaphore._();

  /// Returns the singleton instance of the [Semaphore] class.
  ///
  /// Throws an assertion error if the instance has not been initialized using
  /// [Semaphore.initialize].
  static Semaphore get instance {
    assert(
      _instance._initialized,
      'You must initialize the semaphore instance before calling Semphore.instance',
    );
    return _instance;
  }

  // Flag to track if the instance has been initialized.
  bool _initialized = false;
  // The underlying client for making API calls.
  late SemaphoreClient client;

  /// Initializes the singleton [Semaphore] instance.
  ///
  /// This method must be called before accessing [Semaphore.instance].
  /// It sets up the base URL, optional Dio client, and local storage.
  ///
  /// - [baseUrl]: The base URL for the Semaphore API.
  /// - [dioClient]: An optional custom Dio instance. If not provided, a default one is created.
  /// - [sharedLocalStorage]: An optional custom [LocalStorage] implementation.
  ///   If not provided, [SharedPreferencesLocalStorage] is used.
  static Future<Semaphore> initialize({
    required String baseUrl,
    Dio? dioClient,
    LocalStorage? sharedLocalStorage,
  }) async {
    assert(
      !_instance._initialized,
      'This instance is already initialized',
    );

    // Use default SharedPreferencesLocalStorage if none is provided.
    // The key is generated based on the host part of the baseUrl.
    sharedLocalStorage ??= SharedPreferencesLocalStorage(
      persistSessionKey:
          'sm-${Uri.parse(baseUrl).host.split(".").first}-auth-token',
    );

    // Ensure the local storage is initialized before proceeding.
    await sharedLocalStorage.initialize();

    // Call the private initialization method.
    await _instance._init(
      baseUrl,
      dioClient,
      sharedLocalStorage,
    );

    return _instance;
  }

  /// Private initialization logic for the Semaphore instance.
  ///
  /// Sets up the Dio client and initializes the [SemaphoreClient].
  Future<void> _init(
    String baseUrl,
    Dio? dioClient,
    LocalStorage sharedLocalStorage,
  ) async {
    // Create a default Dio instance if none was provided.
    final dio = dioClient ??
        Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: Constants.defaultConnectTimeout,
            receiveTimeout: Constants.defaultReceiveTimeout,
          ),
        );

    // Create and initialize the SemaphoreClient.
    client = SemaphoreClient(
      dio,
      sharedLocalStorage,
    );
    // Asynchronously initialize the client (e.g., load session, set up interceptors).
    // Note: This is should be called without `await` for non-blocking initialization?
    // if switching to non-blocking, ensure dependent operations handle the client
    // potentially not being fully ready immediately.
    await client.initialize();
    _initialized = true;
  }
}
