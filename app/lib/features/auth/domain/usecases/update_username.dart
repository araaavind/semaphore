import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateUsername implements Usecase<void, String> {
  final AuthRepository authRepository;
  UpdateUsername(this.authRepository);

  @override
  Future<Either<Failure, void>> call(String username) async {
    return await authRepository.updateUsername(username);
  }
}
