import 'package:app/core/errors/failures.dart';
import 'package:app/features/feed/domain/entities/feed_list.dart';
import 'package:app/features/feed/domain/entities/followers_list.dart';
import 'package:app/features/feed/domain/entities/item_list.dart';
import 'package:app/features/feed/domain/entities/liked_item_list.dart';
import 'package:app/features/feed/domain/entities/saved_item_list.dart';
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

  Future<Either<Failure, int>> addAndFollowFeed(String feedUrl);

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
    String after,
    int pageSize,
    String? sortMode,
    String? sessionId,
  });

  Future<Either<Failure, List<Wall>>> listWalls();

  Future<Either<Failure, void>> createWall(String wallName);

  Future<Either<Failure, Wall>> updateWall(int wallId, String wallName);

  Future<Either<Failure, void>> deleteWall(int wallId);

  Future<Either<Failure, void>> addFeedToWall(int feedId, int wallId);

  Future<Either<Failure, void>> removeFeedFromWall(int feedId, int wallId);

  Future<Either<Failure, void>> pinWall(int wallId);

  Future<Either<Failure, void>> unpinWall(int wallId);

  Future<Either<Failure, FeedList>> listWallFeeds({
    required int wallId,
    String? searchKey,
    String? searchValue,
    int page,
    int pageSize,
    String? sortKey,
  });

  Future<Either<Failure, void>> saveItem(int itemId);

  Future<Either<Failure, void>> unsaveItem(int itemId);

  Future<Either<Failure, SavedItemList>> getSavedItems({
    int page,
    int pageSize,
    String? title,
    String? sortKey,
  });

  Future<Either<Failure, List<bool>>> checkUserSavedItems(List<int> itemIds);

  Future<Either<Failure, void>> likeItem(int itemId);

  Future<Either<Failure, void>> unlikeItem(int itemId);

  Future<Either<Failure, LikedItemList>> getLikedItems({
    int page,
    int pageSize,
    String? title,
    String? sortKey,
  });

  Future<Either<Failure, List<bool>>> checkUserLikedItems(List<int> itemIds);

  Future<Either<Failure, int>> getLikeCount(int itemId);
}
