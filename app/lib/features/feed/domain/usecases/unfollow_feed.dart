import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class UnfollowFeed implements Usecase<void, int> {
  FeedRepository feedRepository;
  UnfollowFeed(this.feedRepository);

  @override
  Future<Either<Failure, void>> call(int feedId) async {
    return await feedRepository.unfollowFeed(feedId);
  }
}
