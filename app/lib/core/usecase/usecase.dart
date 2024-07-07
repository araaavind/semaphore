import 'package:app/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class Usecase<SuccessType, ParamsType> {
  Future<Either<Failure, SuccessType>> call(ParamsType params);
}

class NoParams {}
