import 'package:dio/dio.dart';
import 'package:smphr_sdk/src/auth_client.dart';
import 'package:smphr_sdk/src/constants.dart';

class AuthInterceptor extends Interceptor {
  final AuthClient _auth;

  AuthInterceptor({required AuthClient auth}) : _auth = auth;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_auth.currentSession != null) {
      final session = _auth.currentSession!;
      if (session.isExpired) {
        // implement try refresh session
        throw DioException.requestCancelled(
          requestOptions: options,
          reason: Constants.sessionExpiredErrorMessage,
        );
      }

      final bearerToken = session.token;
      options.headers.putIfAbsent("Authorization", () => 'Bearer $bearerToken');
    }

    super.onRequest(options, handler);
  }
}
