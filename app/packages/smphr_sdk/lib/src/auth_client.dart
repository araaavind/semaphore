import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'constants.dart';
import 'local_storage.dart';
import 'types/auth_response.dart';
import 'types/semaphore_exception.dart';
import 'types/internal_exception.dart';
import 'types/session.dart';
import 'types/user.dart';

enum AuthStatus { unkown, authenticated, unauthenticated }

class AuthClient {
  final Dio _dio;
  final LocalStorage _sharedLocalStorage;

  User? _currentUser;
  Session? _currentSession;

  final _authStreamController = StreamController<AuthStatus>();
  Stream<AuthStatus> get status async* {
    yield AuthStatus.unauthenticated;
    yield* _authStreamController.stream;
  }

  void dispose() {
    _authStreamController.close();
  }

  AuthClient({
    required Dio dio,
    required LocalStorage sharedLocalStorage,
  })  : _dio = dio,
        _sharedLocalStorage = sharedLocalStorage;

  /// Creates a new user.
  ///
  /// Returns the created user
  ///
  /// [fullName], is the user's full name
  ///
  /// [email], is the user's email address
  ///
  /// [username], is a unique username that user choses
  ///
  /// [password], is the password of the user
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
      return AuthResponse.fromMap(response.data);
    } on SemaphoreException catch (e) {
      if (kDebugMode) {
        print('SemaphoreException $e.message');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Unknown exception $e.toString()');
      }
      throw InternalException(
        Constants.internalServerErrorMessage,
        statusCode: Constants.httpInternalServerErrorCode,
      );
    }
  }

  /// Sign the user in
  ///
  /// Returns the user and session
  ///
  /// [usernameOrEmail], is the username or email of the user
  ///
  /// [password], is the password of the user
  Future<AuthResponse> signInWithPassword({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/tokens/authentication',
        data: {
          'username_or_email': usernameOrEmail,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromMap(response.data);

      if (authResponse.session?.token != null) {
        await _sharedLocalStorage
            .persistSession(jsonEncode(authResponse.session!.toJson()));
        _saveSession(authResponse.session!);
        _authStreamController.add(AuthStatus.authenticated);
      }
      return authResponse;
    } on SemaphoreException catch (e) {
      if (kDebugMode) {
        print('SemaphoreException $e.message');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Unknown exception $e.toString()');
      }
      throw InternalException(
        Constants.internalServerErrorMessage,
        statusCode: Constants.httpInternalServerErrorCode,
      );
    }
  }

  /// Get the current signed in user after checking the session in server
  ///
  /// Returns the current user
  Future<AuthResponse> getCurrentUser() async {
    try {
      final response = await _dio.get('/me');

      final authResponse = AuthResponse.fromMap(response.data);

      return authResponse;
    } on SemaphoreException catch (e) {
      if (kDebugMode) {
        print('SemaphoreException $e.message');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Unknown exception $e.toString()');
      }
      throw InternalException(
        Constants.internalServerErrorMessage,
        statusCode: Constants.httpInternalServerErrorCode,
      );
    }
  }

  /// Check if username is already taken
  ///
  /// Returns true if username is already taken. Else, false
  ///
  /// [username], is the username of the user
  Future<bool> isUsernameTaken({
    required String username,
  }) async {
    try {
      final response = await _dio.head('/users/$username');

      return response.statusCode == 200;
    } on SemaphoreException catch (e) {
      if (kDebugMode) {
        print('SemaphoreException $e.message');
      }
      if (e.type == DioExceptionType.badResponse &&
          e.subType == SemaphoreExceptionSubType.notFound) {
        // Username is not taken if response is 404
        return false;
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Unknown exception $e.toString()');
      }
      throw InternalException(
        Constants.internalServerErrorMessage,
        statusCode: Constants.httpInternalServerErrorCode,
      );
    }
  }

  /// Signs out the current user, if there is a logged in user.
  ///
  /// [scope] determines which sessions should be logged out.
  ///
  /// [SignOutScope.local], only the current session is logged out.
  ///
  /// [SignOutScope.global], all sessions including the current one are logged out.
  ///
  /// [SignOutScope.others], every session except the current one will be logged out.
  Future<void> signout({SignOutScope scope = SignOutScope.local}) async {
    if (currentSession != null && !currentSession!.isExpired) {
      try {
        await _dio.delete(
          '/tokens/authentication',
          queryParameters: {'scope': scope.name},
        );
      } on SemaphoreException catch (e) {
        if (kDebugMode) {
          print('SemaphoreException $e.message');
        }
        if (e.type == DioExceptionType.badResponse &&
            e.subType == SemaphoreExceptionSubType.unauthorized) {
          // Session is already logged out by other device. Clear session
          await _sharedLocalStorage.removeSession();
          _removeSession();
          _authStreamController.add(AuthStatus.unauthenticated);
          throw SemaphoreException(
            message: Constants.sessionExpiredErrorMessage,
            subType: SemaphoreExceptionSubType.sessionExpired,
            type: e.type,
            requestOptions: e.requestOptions,
            responseStatusCode: 401,
          );
        }
        rethrow;
      } catch (e) {
        if (kDebugMode) {
          print('Unknown exception $e.toString()');
        }
        throw InternalException(
          Constants.internalServerErrorMessage,
          statusCode: Constants.httpInternalServerErrorCode,
        );
      }
    }
    if (scope != SignOutScope.others) {
      await _sharedLocalStorage.removeSession();
      _removeSession();
      _authStreamController.add(AuthStatus.unauthenticated);
    }
  }

  /// Set the initial session to the session obtained from local storage
  ///
  /// This function does not check if the session is expired or not.
  Future<void> setInitialSession(String jsonStr) async {
    final session = Session.fromMap(json.decode(jsonStr));
    // Even though the json session string received may be non-null, fromMap
    // function returns a null session if the token is missing from json string
    if (session == null || session.isExpired) {
      // signout to delete the session from local storage
      await signout();
      return;
    }

    _authStreamController.add(AuthStatus.authenticated);
    _saveSession(session);
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
