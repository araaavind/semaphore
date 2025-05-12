import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/domain/entities/oauth_response.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class LoginWithGoogle {
  final AuthRepository repository;

  const LoginWithGoogle(this.repository);

  Future<Either<Failure, OAuthResponse>> call() async {
    return await repository.loginWithGoogle();
  }
}
