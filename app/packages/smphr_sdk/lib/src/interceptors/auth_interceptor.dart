import 'package:dio/dio.dart';
import 'package:smphr_sdk/src/types/semaphore_exception.dart';

import '../auth_client.dart';
import '../constants.dart';

class AuthInterceptor extends Interceptor {
  final AuthClient _auth;

  AuthInterceptor({required AuthClient auth}) : _auth = auth;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (_auth.currentSession != null) {
      final session = _auth.currentSession!;
      if (session.isExpired) {
        // TODO: implement try refresh session
        await _auth.signout();
        return handler.reject(
          SemaphoreException(
            message: Constants.sessionExpiredErrorMessage,
            type: DioExceptionType.cancel,
            subType: SemaphoreExceptionSubType.sessionExpired,
            requestOptions: options,
          ),
        );
      }

      final bearerToken = _auth.currentSession!.token;
      options.headers.putIfAbsent('Authorization', () => 'Bearer $bearerToken');
    }

    super.onRequest(options, handler);
  }
}
