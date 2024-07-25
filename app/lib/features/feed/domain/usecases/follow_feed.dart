import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class FollowFeedParams {
  final int feedId;
  FollowFeedParams(this.feedId);
}

class FollowFeed implements Usecase<void, FollowFeedParams> {
  FeedRepository feedRepository;
  FollowFeed(this.feedRepository);

  @override
  Future<Either<Failure, void>> call(FollowFeedParams params) async {
    return await feedRepository.followFeed(params.feedId);
  }
}
