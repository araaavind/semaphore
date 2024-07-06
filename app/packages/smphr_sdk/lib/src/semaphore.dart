import 'package:dio/dio.dart';

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
  }) async {
    assert(
      !_instance._initialized,
      'This instance is already initialized',
    );

    _instance._init(
      baseUrl,
      dioClient,
    );

    return _instance;
  }

  void _init(
    String baseUrl,
    Dio? dioClient,
  ) {
    final dio = dioClient ?? Dio();
    dio.options.baseUrl = baseUrl;
    client = SemaphoreClient(
      dio,
    );
    _initialized = true;
  }
}
