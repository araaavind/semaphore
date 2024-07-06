import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:semaphore_dart_connect/semaphore_dart_connect.dart';

abstract interface class AuthRemoteDatasource {
  Future<UserModel> signupWithPassword({
    required String fullName,
    required String email,
    required String username,
    required String password,
  });

  Future<String> loginWithPassword({
    required String usernameOrEmail,
    required String password,
  });
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  SemaphoreClient semaphoreClient;

  AuthRemoteDatasourceImpl(this.semaphoreClient);

  @override
  Future<UserModel> signupWithPassword({
    required String fullName,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await semaphoreClient.auth.signupWithPassword(
        fullName: fullName,
        email: email,
        username: username,
        password: password,
      );

      if (response.user == null) {
        throw const ServerException('User is null!');
      }

      final user = UserModel(
        id: response.user!.id,
        email: response.user!.email,
        username: response.user!.username,
        fullName: response.user!.fullName,
      );

      return user;
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

  @override
  Future<String> loginWithPassword({
    required String usernameOrEmail,
    required String password,
  }) {
    // TODO: implement loginWithPassword
    throw UnimplementedError();
  }
}
