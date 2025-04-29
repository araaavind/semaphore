import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SendPasswordResetToken implements Usecase<String, String> {
  final AuthRepository authRepository;
  SendPasswordResetToken(this.authRepository);

  @override
  Future<Either<Failure, String>> call(String email) async {
    return await authRepository.sendPasswordResetToken(email);
  }
}
