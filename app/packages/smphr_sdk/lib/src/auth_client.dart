import 'package:dio/dio.dart';

import 'constants.dart';
import 'types/auth_exception.dart';
import 'types/auth_response.dart';
import 'types/error_response.dart';
import 'types/semaphore_exception.dart';
// import 'package:smphr_sdk/src/constants.dart';
// import 'package:smphr_sdk/src/types/auth_exception.dart';
// import 'package:smphr_sdk/src/types/auth_response.dart';
// import 'package:smphr_sdk/src/types/error_response.dart';
// import 'package:smphr_sdk/src/types/semaphore_exception.dart';

class AuthClient {
  final Dio _dio;

  AuthClient(Dio dio) : _dio = dio;

  Future<AuthResponse> signupWithPassword({
    required String fullName,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/users',
        data: {
          'full_name': fullName,
          'email': email,
          'username': username,
          'password': password,
        },
      );
      final user = AuthResponse.fromMap(response.data);
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errRes = ErrorResponse.fromMap(e.response?.data);
        if (errRes.fieldErrors != null) {
          errRes.fieldErrors!.forEach((field, message) {
            switch (field) {
              case 'full_name':
                throw AuthException('Full name $message');
              case 'email':
                throw AuthException('Email $message');
              case 'username':
                throw AuthException('Username $message');
              case 'password':
                throw AuthException('Password $message');
              default:
                throw AuthException('Something went wrong. Check the inputs.');
            }
          });
        }
        throw AuthException(
          errRes.message,
          statusCode: e.response?.statusCode,
        );
      }
      print(e.message);
      throw SemaphoreException(
        Constants.internalServerErrorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      print(e.toString());
      throw SemaphoreException(
        Constants.internalServerErrorMessage,
        statusCode: Constants.httpInternalServerErrorCode,
      );
    }
  }
}
