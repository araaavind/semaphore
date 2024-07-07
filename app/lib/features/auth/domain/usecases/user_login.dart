import 'package:app/core/common/entities/user.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserLoginParams {
  final String usernameOrEmail;
  final String password;

  UserLoginParams({
    required this.usernameOrEmail,
    required this.password,
  });
}

class UserLogin implements Usecase<User, UserLoginParams> {
  final AuthRepository authRepository;

  UserLogin(this.authRepository);

  @override
  Future<Either<Failure, User>> call(UserLoginParams params) async {
    return await authRepository.loginWithPassword(
      usernameOrEmail: params.usernameOrEmail,
      password: params.password,
    );
  }
}
