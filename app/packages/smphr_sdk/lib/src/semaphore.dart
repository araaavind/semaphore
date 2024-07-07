import 'package:dio/dio.dart';

import 'constants.dart';
import 'local_storage.dart';
import 'interceptors/error_interceptor.dart';
import 'semaphore_client.dart';

class Semaphore {
  Semaphore._();
  static final Semaphore _instance = Semaphore._();

  static Semaphore get instance {
    assert(
      _instance._initialized,
      'You must initialize the semaphore instance before calling Semphore.instance',
    );
    return _instance;
  }

  bool _initialized = false;
  late SemaphoreClient client;

  static Future<Semaphore> initialize({
    required String baseUrl,
    Dio? dioClient,
    LocalStorage? sharedLocalStorage,
  }) async {
    assert(
      !_instance._initialized,
      'This instance is already initialized',
    );

    // if sessionLocalStorage == null => create new using SharedPreferencesLocalStorage
    sharedLocalStorage ??= SharedPreferencesLocalStorage(
      persistSessionKey:
          'sm-${Uri.parse(baseUrl).host.split(".").first}-auth-token',
    );

    await sharedLocalStorage.initialize();

    _instance._init(
      baseUrl,
      dioClient,
      sharedLocalStorage,
    );

    return _instance;
  }

  void _init(
    String baseUrl,
    Dio? dioClient,
    LocalStorage sharedLocalStorage,
  ) async {
    final dio = dioClient ??
        Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: Constants.defaultConnectTimeout,
            receiveTimeout: Constants.defaultReceiveTimeout,
          ),
        );

    dio.interceptors.add(ErrorInterceptor());
    client = SemaphoreClient(
      dio,
      sharedLocalStorage,
    );
    await client.initialize();
    _initialized = true;
  }
}
