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
  Future<Either<Failure, UserModel>> signupWithPassword({
    required String fullName,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final user = await remoteDatasource.signupWithPassword(
        fullName: fullName,
        email: email,
        username: username,
        password: password,
      );

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserModel>> loginWithPassword({
    required String usernameOrEmail,
    required String password,
  }) {
    // TODO: implement loginWithPassword
    throw UnimplementedError();
  }
}
