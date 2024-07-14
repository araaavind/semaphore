import 'package:dio/dio.dart';

import '../auth_client.dart';
import '../constants.dart';
import '../types/auth_exception.dart';

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
        throw DioException.requestCancelled(
          requestOptions: options,
          reason: SessionExpiredException(Constants.sessionExpiredErrorMessage),
        );
      }

      final bearerToken = _auth.currentSession!.token;
      options.headers.putIfAbsent('Authorization', () => 'Bearer $bearerToken');
    }

    super.onRequest(options, handler);
  }
}
