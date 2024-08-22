import 'package:app/core/errors/failures.dart';
import 'package:app/features/feed/domain/entities/feed_list.dart';
import 'package:app/features/feed/domain/entities/followers_list.dart';
import 'package:app/features/feed/domain/entities/item_list.dart';
import 'package:app/features/feed/domain/entities/wall.dart';
import 'package:app/features/feed/presentation/bloc/list_items/list_items_bloc.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class FeedRepository {
  Future<Either<Failure, FeedList>> listAllFeeds({
    String? searchKey,
    String? searchValue,
    int page,
    int pageSize,
    String? sortKey,
  });

  Future<Either<Failure, void>> addAndFollowFeed(String feedUrl);

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

  Future<Either<Failure, ItemList>> listItems({
    required int parentId,
    required ListItemsParentType parentType,
    String? searchKey,
    String? searchValue,
    int page,
    int pageSize,
    String? sortKey,
  });

  Future<Either<Failure, List<Wall>>> listWalls();

  Future<Either<Failure, void>> createWall(String wallName);
}
