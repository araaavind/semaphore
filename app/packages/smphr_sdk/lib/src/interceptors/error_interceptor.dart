import 'package:dio/dio.dart';

import '../auth_client.dart';
import '../constants.dart';
import '../types/network_exception.dart';

class ErrorInterceptor extends Interceptor {
  final AuthClient _auth;

  ErrorInterceptor({required AuthClient auth}) : _auth = auth;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionError:
        err = NetworkException(
          message: Constants.connectionErrorMessage,
          requestOptions: err.requestOptions,
        );
        break;
      case DioExceptionType.connectionTimeout:
        err = NetworkException(
          message: Constants.connectionTimeoutErrorMessage,
          requestOptions: err.requestOptions,
        );
        break;
      case DioExceptionType.receiveTimeout:
        err = NetworkException(
          message: Constants.receiveTimeoutErrorMessage,
          requestOptions: err.requestOptions,
        );
        break;
      case DioExceptionType.unknown:
        err = NetworkException(
          message: Constants.internalServerErrorMessage,
          requestOptions: err.requestOptions,
        );
        break;
      case DioExceptionType.badResponse:
        if (err.response != null && err.response!.statusCode == 401) {
          _auth.signout();
        }
        break;
      default:
        err = NetworkException(
          message: Constants.internalServerErrorMessage,
          requestOptions: err.requestOptions,
        );
        break;
    }
    super.onError(err, handler);
  }
}
