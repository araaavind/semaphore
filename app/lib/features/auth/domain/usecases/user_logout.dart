import 'package:app/core/constants/server_constants.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserLogoutParams {
  final LogoutScope scope;

  UserLogoutParams({this.scope = LogoutScope.local});
}

class UserLogout implements Usecase<void, UserLogoutParams> {
  final AuthRepository authRepository;
  UserLogout(this.authRepository);

  @override
  Future<Either<Failure, void>> call(UserLogoutParams params) async {
    return await authRepository.logout(scope: params.scope);
  }
}
