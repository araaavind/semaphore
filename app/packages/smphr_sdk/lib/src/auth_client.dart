import 'dart:convert';

import 'package:dio/dio.dart';

import 'constants.dart';
import 'types/auth_exception.dart';
import 'types/auth_response.dart';
import 'types/error_response.dart';
import 'types/semaphore_exception.dart';
import 'types/session.dart';
import 'types/user.dart';

class AuthClient {
  final Dio _dio;

  User? _currentUser;
  Session? _currentSession;

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

  /// Set the initial session to the session obtained from local storage
  Future<void> setInitialSession(String jsonStr) async {
    final session = Session.fromJson(json.decode(jsonStr));
    if (session == null) {
      // sign out to delete the local storage from supabase_flutter
      UnimplementedError('Implement signout if session does not exist');
    }

    _saveSession(session!);
  }

  /// Returns the current logged in user, if any;
  ///
  /// Use [currentSession] to determine whether the user has an active session,
  /// because [currentUser] can be non-null without an active session, such as
  /// when the user signed up using email and password but has not confirmed
  /// their email address.
  User? get currentUser => _currentUser;

  /// Returns the current session, if any;
  Session? get currentSession => _currentSession;

  void _saveSession(Session session) {
    _currentSession = session;
    _currentUser = session.user;
  }

  void _removeSession() {
    _currentSession = null;
    _currentUser = null;
  }
}
