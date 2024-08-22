import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateWall implements Usecase<void, String> {
  FeedRepository feedRepository;
  CreateWall(this.feedRepository);

  @override
  Future<Either<Failure, void>> call(String wallName) async {
    return await feedRepository.createWall(wallName);
  }
}
