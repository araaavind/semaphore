import 'package:dio/dio.dart';

import '../auth_client.dart';
import '../constants.dart';
import '../types/error_response.dart';
import '../types/semaphore_exception.dart';

class ErrorInterceptor extends Interceptor {
  final AuthClient _auth;

  ErrorInterceptor({required AuthClient auth}) : _auth = auth;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err is SemaphoreException) {
      super.onError(err, handler);
      return;
    }
    switch (err.type) {
      case DioExceptionType.connectionError:
        err = SemaphoreException(
          message: Constants.connectionErrorMessage,
          requestOptions: err.requestOptions,
          type: err.type,
          subType: SemaphoreExceptionSubType.connectionFailed,
        );
        break;
      case DioExceptionType.connectionTimeout:
        err = SemaphoreException(
          message: Constants.connectionTimeoutErrorMessage,
          requestOptions: err.requestOptions,
          type: err.type,
          subType: SemaphoreExceptionSubType.connectionFailed,
        );
        break;
      case DioExceptionType.receiveTimeout:
        err = SemaphoreException(
          message: Constants.receiveTimeoutErrorMessage,
          requestOptions: err.requestOptions,
          type: err.type,
          subType: SemaphoreExceptionSubType.none,
        );
        break;
      case DioExceptionType.badResponse:
        if (err.response != null && err.response!.statusCode == 404) {
          err = SemaphoreException(
            subType: SemaphoreExceptionSubType.notFound,
            message: Constants.notFoundErrorMessage,
            type: err.type,
            requestOptions: err.requestOptions,
            responseStatusCode: 404,
          );
        } else if (err.response != null && err.response!.statusCode == 401) {
          final errRes = ErrorResponse.fromMap(err.response?.data);
          if (err.requestOptions.path != '/tokens/authentication' ||
              err.requestOptions.method != 'DELETE') {
            try {
              await _auth.signout();
            } catch (e) {
              if (e is SemaphoreException) {
                err = e;
              } else {
                print('63 error ${err.response}');
                err = SemaphoreException(
                  subType: SemaphoreExceptionSubType.none,
                  message: Constants.internalServerErrorMessage,
                  type: DioExceptionType.unknown,
                  requestOptions: err.requestOptions,
                );
              }
            }
          }
          err = SemaphoreException(
            subType: SemaphoreExceptionSubType.unauthorized,
            type: err.type,
            requestOptions: err.requestOptions,
            responseStatusCode: 401,
            message: errRes.message,
          );
        } else if (err.response != null && err.response!.statusCode == 422) {
          final errRes = ErrorResponse.fromMap(err.response?.data);
          if (errRes.fieldErrors != null && errRes.fieldErrors!.isNotEmpty) {
            err = SemaphoreException(
              message: Constants.invalidInputErrorMessage,
              subType: SemaphoreExceptionSubType.invalidField,
              type: err.type,
              requestOptions: err.requestOptions,
              fieldErrors: errRes.fieldErrors,
              responseStatusCode: 422,
            );
          } else {
            err = SemaphoreException(
              message: errRes.message,
              subType: SemaphoreExceptionSubType.unprocessableEntity,
              type: err.type,
              requestOptions: err.requestOptions,
              responseStatusCode: 422,
            );
          }
        } else if (err.response != null && err.response!.statusCode == 403) {
          final errRes = ErrorResponse.fromMap(err.response?.data);
          err = SemaphoreException(
            subType: SemaphoreExceptionSubType.forbidden,
            message: errRes.message,
            type: err.type,
            requestOptions: err.requestOptions,
            responseStatusCode: 403,
          );
        } else {
          print('110 error ${err.response}');
          err = SemaphoreException(
            message: Constants.internalServerErrorMessage,
            responseStatusCode: err.response?.statusCode,
            subType: SemaphoreExceptionSubType.none,
            type: err.type,
            requestOptions: err.requestOptions,
          );
        }
        break;
      case DioExceptionType.cancel:
        if (err.error != null && err.error is SemaphoreException) {
          err = err.error as SemaphoreException;
        }
        break;
      default:
        print('125 error ${err.response}');
        err = SemaphoreException(
          message: Constants.internalServerErrorMessage,
          requestOptions: err.requestOptions,
          type: DioExceptionType.unknown,
          subType: SemaphoreExceptionSubType.unknown,
        );
        break;
    }
    super.onError(err, handler);
  }
}
