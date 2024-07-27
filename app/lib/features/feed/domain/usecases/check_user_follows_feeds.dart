import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class CheckUserFollowsFeeds implements Usecase<List<bool>, List<int>> {
  FeedRepository feedRepository;
  CheckUserFollowsFeeds(this.feedRepository);

  @override
  Future<Either<Failure, List<bool>>> call(List<int> feedIds) async {
    return await feedRepository.checkUserFollowsFeeds(feedIds);
  }
}
