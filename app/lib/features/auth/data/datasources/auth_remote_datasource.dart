import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:smphr_sdk/smphr_sdk.dart';

abstract interface class AuthRemoteDatasource {
  Session? get currentSession;

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

  UserModel? get currentUser;
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  SemaphoreClient semaphoreClient;

  AuthRemoteDatasourceImpl(this.semaphoreClient);

  @override
  Session? get currentSession {
    final session = semaphoreClient.auth.currentSession;
    return session;
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

  Future<UserModel> _tryAuthRequest(Future<AuthResponse> Function() fn) async {
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
      );
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } on SemaphoreException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
      throw ServerException(e.toString());
    }
  }
}
