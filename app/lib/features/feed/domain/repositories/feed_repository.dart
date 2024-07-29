import 'package:app/core/errors/failures.dart';
import 'package:app/features/feed/domain/entities/feed_list.dart';
import 'package:app/features/feed/domain/entities/followers_list.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class FeedRepository {
  Future<Either<Failure, FeedList>> listAllFeeds({
    String? searchKey,
    String? searchValue,
    int page,
    int pageSize,
    String? sortKey,
  });

  Future<Either<Failure, void>> followFeed(int feedId);

  Future<Either<Failure, void>> unfollowFeed(int feedId);

  Future<Either<Failure, FeedList>> listFeedsFollowedByCurrentUser({
    String? searchKey,
    String? searchValue,
    int page,
    int pageSize,
    String? sortKey,
  });

  Future<Either<Failure, List<bool>>> checkUserFollowsFeeds(List<int> feedIds);

  Future<Either<Failure, FollowersList>> listFollowersOfFeed({
    required int feedId,
    String? searchKey,
    String? searchValue,
    int page,
    int pageSize,
    String? sortKey,
  });
}
