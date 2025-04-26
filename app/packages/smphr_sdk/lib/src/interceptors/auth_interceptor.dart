import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:smphr_sdk/src/types/semaphore_exception.dart';

import '../auth_client.dart';
import '../constants.dart';

class AuthInterceptor extends Interceptor {
  final AuthClient _auth;
  // Lock to prevent concurrent token refresh requests
  final _tokenRefreshLock = Lock();

  AuthInterceptor({required AuthClient auth}) : _auth = auth;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_auth.currentSession != null) {
      final session = _auth.currentSession!;

      // Check if the token is expired
      if (session.isExpired) {
        try {
          // Use the lock to prevent multiple concurrent refresh requests
          await _tokenRefreshLock.lock();

          // Double-check if token is still expired after waiting for the lock
          // This prevents unnecessary refresh calls if another request already refreshed the token
          if (_auth.currentSession!.isExpired) {
            // If refresh token is also expired, sign out and reject the request
            if (_auth.currentSession!.isRefreshTokenExpired) {
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

            try {
              // Attempt to refresh the token
              await _auth.refreshToken();
            } catch (e) {
              if (kDebugMode) {
                print('Token refresh failed: ${e.toString()}');
              }
              return handler.reject(
                SemaphoreException(
                  message: Constants.tokenRefreshErrorMessage,
                  type: DioExceptionType.cancel,
                  subType: SemaphoreExceptionSubType.sessionExpired,
                  requestOptions: options,
                ),
              );
            }
          }
        } finally {
          _tokenRefreshLock.unlock();
        }
      }

      // Get the latest token (which might have been refreshed)
      final bearerToken = _auth.currentSession!.token;
      options.headers.putIfAbsent('Authorization', () => 'Bearer $bearerToken');
    }

    super.onRequest(options, handler);
  }
}

// Simple lock implementation for managing async token refresh
class Lock {
  Completer<void>? _completer;

  bool get locked => _completer != null;

  Future<void> lock() async {
    if (_completer != null) {
      await _completer!.future;
      return lock();
    }
    _completer = Completer<void>();
    return;
  }

  void unlock() {
    if (_completer == null) {
      return;
    }
    final completer = _completer!;
    _completer = null;
    completer.complete();
  }
}
