import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class ResetPasswordParams {
  final String token;
  final String password;

  ResetPasswordParams({required this.token, required this.password});
}

class ResetPassword implements Usecase<void, ResetPasswordParams> {
  final AuthRepository authRepository;
  ResetPassword(this.authRepository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    return await authRepository.resetPassword(params.token, params.password);
  }
}
