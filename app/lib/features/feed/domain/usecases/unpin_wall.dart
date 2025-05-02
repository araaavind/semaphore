import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class UnpinWall implements Usecase<void, int> {
  FeedRepository feedRepository;
  UnpinWall(this.feedRepository);

  @override
  Future<Either<Failure, void>> call(int wallId) async {
    return await feedRepository.unpinWall(wallId);
  }
}
