import 'package:app/core/common/entities/user.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserSignupParams {
  final String fullName;
  final String email;
  final String username;
  final String password;

  UserSignupParams({
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
  });
}

class UserSignup implements Usecase<User, UserSignupParams> {
  final AuthRepository authRepository;

  UserSignup(this.authRepository);

  @override
  Future<Either<Failure, User>> call(UserSignupParams params) async {
    return await authRepository.signupWithPassword(
      fullName: params.fullName,
      email: params.email,
      username: params.username,
      password: params.password,
    );
  }
}
