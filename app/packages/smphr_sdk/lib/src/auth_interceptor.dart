import 'package:dio/dio.dart';
import 'package:smphr_sdk/src/auth_client.dart';

class AuthInterceptor extends Interceptor {
  final AuthClient _auth;

  AuthInterceptor({required AuthClient auth}) : _auth = auth;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_auth.currentSession?.isExpired ?? false) {
      // implement try refresh session
    }

    final bearerToken = _auth.currentSession!.token;
    options.headers.putIfAbsent("Authorization", () => 'Bearer $bearerToken');

    super.onRequest(options, handler);
  }
}
