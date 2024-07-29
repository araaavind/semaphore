import 'package:app/core/common/entities/logout_scope.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/common/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:smphr_sdk/smphr_sdk.dart' as sp;

abstract interface class AuthRemoteDatasource {
  sp.Session? get currentSession;
  Future<UserModel?> getCurrentUser();

  Future<bool> checkUsername({required String username});

  Future<UserModel> signupWithPassword({
    required String fullName,
    required String email,
    required String username,
    required String password,
  });

  Future<UserModel> loginWithPassword({
    required String usernameOrEmail,
    required String password,
  });

  Future<void> logout({LogoutScope scope = LogoutScope.local});
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  sp.SemaphoreClient semaphoreClient;

  AuthRemoteDatasourceImpl(this.semaphoreClient);

  @override
  sp.Session? get currentSession => semaphoreClient.auth.currentSession;

  @override
  Future<UserModel?> getCurrentUser() async {
    if (currentSession != null) {
      return _tryAuthRequest(
        () async => await semaphoreClient.auth.getCurrentUser(),
      );
    }
    return null;
  }

  @override
  Future<bool> checkUsername({required String username}) async {
    try {
      return await semaphoreClient.auth.isUsernameTaken(username: username);
    } on sp.SemaphoreException catch (e) {
      if (e.subType == sp.SemaphoreExceptionSubType.invalidField &&
          e.fieldErrors != null &&
          e.fieldErrors!.isNotEmpty) {
        throw ServerException(e.message!, fieldErrors: e.fieldErrors);
      }
      throw ServerException(e.message!);
    } on sp.InternalException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
      throw const ServerException(TextConstants.internalServerErrorMessage);
    }
  }

  @override
  Future<UserModel> signupWithPassword({
    required String fullName,
    required String email,
    required String username,
    required String password,
  }) async {
    return _tryAuthRequest(
      () async => await semaphoreClient.auth.signupWithPassword(
        fullName: fullName,
        email: email,
        username: username,
        password: password,
      ),
    );
  }

  @override
  Future<UserModel> loginWithPassword({
    required String usernameOrEmail,
    required String password,
  }) async {
    return _tryAuthRequest(
      () async => await semaphoreClient.auth.signInWithPassword(
        usernameOrEmail: usernameOrEmail,
        password: password,
      ),
    );
  }

  Future<UserModel> _tryAuthRequest(
      Future<sp.AuthResponse> Function() fn) async {
    try {
      final response = await fn();
      if (response.user == null) {
        throw const ServerException('User is null');
      }
      return UserModel(
        email: response.user!.email,
        fullName: response.user!.fullName,
        id: response.user!.id,
        username: response.user!.username,
        lastLoginAt: response.user!.lastLoginAt,
      );
    } on sp.SemaphoreException catch (e) {
      // Return local session and keep user logged if connection fails
      if (e.subType == sp.SemaphoreExceptionSubType.connectionFailed) {
        if (currentSession != null &&
            !currentSession!.isExpired &&
            currentSession!.user != null) {
          return UserModel(
            email: currentSession!.user!.email,
            fullName: currentSession!.user!.fullName,
            id: currentSession!.user!.id,
            username: currentSession!.user!.username,
            lastLoginAt: currentSession!.user!.lastLoginAt,
          );
        }
      }
      if (e.subType == sp.SemaphoreExceptionSubType.invalidField &&
          e.fieldErrors != null &&
          e.fieldErrors!.isNotEmpty) {
        throw ServerException(e.message!, fieldErrors: e.fieldErrors);
      }
      throw ServerException(e.message!);
    } on sp.InternalException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
      throw const ServerException(TextConstants.internalServerErrorMessage);
    }
  }

  @override
  Future<void> logout({LogoutScope scope = LogoutScope.local}) async {
    try {
      await semaphoreClient.auth.signout(
        scope: sp.SignOutScope.fromString(scope.name),
      );
    } on sp.SemaphoreException catch (e) {
      throw ServerException(e.message!);
    } on sp.InternalException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
        throw const ServerException(TextConstants.internalServerErrorMessage);
      }
    }
  }
}
