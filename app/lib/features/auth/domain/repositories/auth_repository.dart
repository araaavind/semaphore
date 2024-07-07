import 'package:app/core/common/entities/user.dart';
import 'package:app/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Either<Failure, User> get currentUser;

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
}
