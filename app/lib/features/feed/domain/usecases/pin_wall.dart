import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class PinWall implements Usecase<void, int> {
  FeedRepository feedRepository;
  PinWall(this.feedRepository);

  @override
  Future<Either<Failure, void>> call(int wallId) async {
    return await feedRepository.pinWall(wallId);
  }
}
