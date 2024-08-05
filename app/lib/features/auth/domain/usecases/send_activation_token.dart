import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SendActivationToken implements Usecase<void, String> {
  final AuthRepository authRepository;
  SendActivationToken(this.authRepository);

  @override
  Future<Either<Failure, String>> call(String email) async {
    return await authRepository.sendActivationToken(email);
  }
}
