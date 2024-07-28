import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class UnfollowFeedParams {
  final int feedId;
  UnfollowFeedParams(this.feedId);
}

class UnfollowFeed implements Usecase<void, UnfollowFeedParams> {
  FeedRepository feedRepository;
  UnfollowFeed(this.feedRepository);

  @override
  Future<Either<Failure, void>> call(UnfollowFeedParams params) async {
    return await feedRepository.unfollowFeed(params.feedId);
  }
}
