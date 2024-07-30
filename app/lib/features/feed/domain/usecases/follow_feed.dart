import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class FollowFeed implements Usecase<void, int> {
  FeedRepository feedRepository;
  FollowFeed(this.feedRepository);

  @override
  Future<Either<Failure, void>> call(int feedId) async {
    return await feedRepository.followFeed(feedId);
  }
}
