import 'package:app/core/common/entities/logout_scope.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/common/models/user_model.dart';
import 'package:app/features/auth/data/models/oauth_response_model.dart';
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

  Future<OAuthResponseModel> loginWithGoogle();

  Future<void> logout({LogoutScope scope = LogoutScope.local});

  Future<String> sendActivationToken(String email);

  Future<void> activateUser(String token);

  Future<String> sendPasswordResetToken(String email);

  Future<void> resetPassword(String token, String password);

  Future<void> updateUsername(String username);
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

  @override
  Future<OAuthResponseModel> loginWithGoogle() async {
    try {
      final response = await semaphoreClient.auth.signInWithGoogle();
      if (response.user == null) {
        throw const ServerException('User is null');
      }
      return OAuthResponseModel(
        user: UserModel(
          email: response.user!.email,
          fullName: response.user!.fullName,
          id: response.user!.id,
          username: response.user!.username,
          lastLoginAt: response.user!.lastLoginAt,
          isActivated: response.user!.isActivated,
        ),
        isNewUser: response.isNewUser,
      );
    } on sp.SemaphoreException catch (e) {
      // Return local session and keep user logged if connection fails
      if (e.subType == sp.SemaphoreExceptionSubType.connectionFailed) {
        if (currentSession != null &&
            !currentSession!.isExpired &&
            currentSession!.user != null) {
          return OAuthResponseModel(
            user: UserModel(
              email: currentSession!.user!.email,
              fullName: currentSession!.user!.fullName,
              id: currentSession!.user!.id,
              username: currentSession!.user!.username,
              lastLoginAt: currentSession!.user!.lastLoginAt,
              isActivated: currentSession!.user!.isActivated,
            ),
            isNewUser: false,
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
        isActivated: response.user!.isActivated,
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
            isActivated: currentSession!.user!.isActivated,
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

  @override
  Future<String> sendActivationToken(String email) async {
    try {
      final response = await semaphoreClient.dio.post(
        '/tokens/activation',
        data: {
          'email': email,
        },
      );
      return response.data['message'];
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
        print('Unknown exception $e.toString()');
      }
      throw const ServerException(TextConstants.internalServerErrorMessage);
    }
  }

  @override
  Future<void> activateUser(String token) async {
    try {
      await semaphoreClient.dio.put(
        '/users/activate',
        data: {
          'token': token,
        },
      );
      return;
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
        print('Unknown exception $e.toString()');
      }
      throw const ServerException(TextConstants.internalServerErrorMessage);
    }
  }

  @override
  Future<String> sendPasswordResetToken(String email) async {
    try {
      final response = await semaphoreClient.dio.post(
        '/tokens/password-reset',
        data: {
          'email': email,
        },
      );
      return response.data['message'];
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
        print('Unknown exception $e.toString()');
      }
      throw const ServerException(TextConstants.internalServerErrorMessage);
    }
  }

  @override
  Future<void> resetPassword(String token, String password) async {
    try {
      await semaphoreClient.dio.put(
        '/users/password',
        data: {
          'token': token,
          'password': password,
        },
      );
      return;
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
        print('Unknown exception $e.toString()');
      }
      throw const ServerException(TextConstants.internalServerErrorMessage);
    }
  }

  @override
  Future<void> updateUsername(String username) async {
    try {
      await semaphoreClient.dio.put(
        '/users/username',
        data: {
          'username': username,
        },
      );
      return;
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
        print('Unknown exception $e.toString()');
      }
      throw const ServerException(TextConstants.internalServerErrorMessage);
    }
  }
}
