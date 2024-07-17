import 'package:app/core/common/entities/logout_scope.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  const AuthRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      final session = remoteDatasource.currentSession;
      if (session == null) {
        return left(const Failure('User not logged in'));
      }
      final user = await remoteDatasource.getCurrentUser();
      if (user == null) {
        return left(const Failure('User not logged in'));
      }
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> checkUsername({
    required String username,
  }) async {
    try {
      final usernameTaken =
          await remoteDatasource.checkUsername(username: username);
      return right(usernameTaken);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signupWithPassword({
    required String fullName,
    required String email,
    required String username,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDatasource.signupWithPassword(
        fullName: fullName,
        email: email,
        username: username,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, UserModel>> loginWithPassword({
    required String usernameOrEmail,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDatasource.loginWithPassword(
        usernameOrEmail: usernameOrEmail,
        password: password,
      ),
    );
  }

  Future<Either<Failure, UserModel>> _getUser(
    Future<UserModel> Function() fn,
  ) async {
    try {
      final user = await fn();
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout({
    LogoutScope scope = LogoutScope.local,
  }) async {
    try {
      return right(await remoteDatasource.logout(scope: scope));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
