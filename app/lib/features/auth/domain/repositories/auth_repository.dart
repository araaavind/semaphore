import 'package:app/core/common/entities/logout_scope.dart';
import 'package:app/core/common/entities/user.dart';
import 'package:app/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, bool>> checkUsername({required String username});

  Future<Either<Failure, User>> signupWithPassword({
    required String fullName,
    required String email,
    required String username,
    required String password,
  });

  Future<Either<Failure, User>> loginWithPassword({
    required String usernameOrEmail,
    required String password,
  });

  Future<Either<Failure, void>> logout({
    LogoutScope scope = LogoutScope.local,
  });

  Future<Either<Failure, String>> sendActivationToken(String email);
  Future<Either<Failure, void>> activateUser(String token);
}
