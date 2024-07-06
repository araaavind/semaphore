import 'package:dio/dio.dart';

import 'local_storage.dart';
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
    LocalStorage? sessionLocalStorage,
  }) async {
    assert(
      !_instance._initialized,
      'This instance is already initialized',
    );

    // if sessionLocalStorage == null => create new using SharedPreferencesLocalStorage
    sessionLocalStorage ??= SharedPreferencesLocalStorage(
      persistSessionKey:
          'sb-${Uri.parse(baseUrl).host.split(".").first}-auth-token',
    );

    await sessionLocalStorage.initialize();

    _instance._init(
      baseUrl,
      dioClient,
      sessionLocalStorage,
    );

    return _instance;
  }

  void _init(
    String baseUrl,
    Dio? dioClient,
    LocalStorage sessionLocalStorage,
  ) async {
    final dio = dioClient ?? Dio();
    dio.options.baseUrl = baseUrl;

    client = SemaphoreClient(
      dio,
      sessionLocalStorage,
    );
    await client.initialize();
    _initialized = true;
  }
}
