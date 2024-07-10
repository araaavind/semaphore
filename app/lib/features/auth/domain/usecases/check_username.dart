import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class CheckUsernameParams {
  final String username;

  CheckUsernameParams(this.username);
}

class CheckUsername implements Usecase<bool, CheckUsernameParams> {
  final AuthRepository authRepository;

  CheckUsername(this.authRepository);

  @override
  Future<Either<Failure, bool>> call(CheckUsernameParams params) async {
    return await authRepository.checkUsername(username: params.username);
  }
}
