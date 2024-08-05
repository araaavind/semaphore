import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class ActivateUser implements Usecase<void, String> {
  final AuthRepository authRepository;
  ActivateUser(this.authRepository);

  @override
  Future<Either<Failure, void>> call(String token) async {
    return await authRepository.activateUser(token);
  }
}
