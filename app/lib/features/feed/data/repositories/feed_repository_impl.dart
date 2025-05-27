import 'package:app/core/constants/server_constants.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/feed/data/datasources/feed_remote_datasource.dart';
import 'package:app/features/feed/data/models/feed_list_model.dart';
import 'package:app/features/feed/data/models/followers_list_model.dart';
import 'package:app/features/feed/data/models/item_list_model.dart';
import 'package:app/features/feed/data/models/liked_item_list_model.dart';
import 'package:app/features/feed/data/models/saved_item_list_model.dart';
import 'package:app/features/feed/data/models/topic_model.dart';
import 'package:app/features/feed/data/models/wall_model.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:app/features/feed/presentation/bloc/list_items/list_items_bloc.dart';
import 'package:fpdart/fpdart.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRemoteDatasource feedRemoteDatasource;

  FeedRepositoryImpl(this.feedRemoteDatasource);

  @override
  Future<Either<Failure, List<TopicModel>>> listTopics() async {
    try {
      final topicsList = await feedRemoteDatasource.listTopics();
      return right(topicsList);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, FeedListModel>> listAllFeeds({
    String? searchKey,
    String? searchValue,
    int? topicId,
    int page = 1,
    int pageSize = ServerConstants.defaultPaginationPageSize,
    String? sortKey,
  }) async {
    try {
      final feedsList = await feedRemoteDatasource.listAllFeeds(
        searchKey: searchKey,
        searchValue: searchValue,
        topicId: topicId,
        page: page,
        pageSize: pageSize,
        sortKey: sortKey,
      );

      return right(feedsList);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, int>> addAndFollowFeed(String feedUrl) async {
    try {
      return right(
        await feedRemoteDatasource.addAndFollowFeed(feedUrl),
      );
    } on ServerException catch (e) {
      return left(Failure(message: e.message, fieldErrors: e.fieldErrors));
    }
  }

  @override
  Future<Either<Failure, void>> followFeed(int feedId) async {
    try {
      return right(
        await feedRemoteDatasource.followFeed(feedId),
      );
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> unfollowFeed(int feedId) async {
    try {
      return right(
        await feedRemoteDatasource.unfollowFeed(feedId),
      );
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, FeedListModel>> listFeedsFollowedByCurrentUser({
    String? searchKey,
    String? searchValue,
    int page = 1,
    int pageSize = ServerConstants.defaultPaginationPageSize,
    String? sortKey,
  }) async {
    try {
      final feedsList =
          await feedRemoteDatasource.listFeedsFollowedByCurrentUser(
        searchKey: searchKey,
        searchValue: searchValue,
        page: page,
        pageSize: pageSize,
        sortKey: sortKey,
      );
      return right(feedsList);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<bool>>> checkUserFollowsFeeds(
      List<int> feedIds) async {
    try {
      return right(
        await feedRemoteDatasource.checkUserFollowsFeeds(feedIds),
      );
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, FollowersListModel>> listFollowersOfFeed({
    required int feedId,
    String? searchKey,
    String? searchValue,
    int page = 1,
    int pageSize = ServerConstants.defaultPaginationPageSize,
    String? sortKey,
  }) async {
    try {
      final followersList = await feedRemoteDatasource.listFollowersOfFeed(
        feedId: feedId,
        searchKey: searchKey,
        searchValue: searchValue,
        page: page,
        pageSize: pageSize,
        sortKey: sortKey,
      );
      return right(followersList);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, ItemListModel>> listItems({
    required int parentId,
    required ListItemsParentType parentType,
    String? searchKey,
    String? searchValue,
    String after = '',
    int pageSize = ServerConstants.defaultPaginationPageSize,
    String? sortMode,
    String? sessionId,
  }) async {
    try {
      final itemsList = await feedRemoteDatasource.listItems(
        parentId: parentId,
        parentType: parentType,
        searchKey: searchKey,
        searchValue: searchValue,
        after: after,
        pageSize: pageSize,
        sortMode: sortMode,
        sessionId: sessionId,
      );
      return right(itemsList);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<WallModel>>> listWalls() async {
    try {
      final wallsList = await feedRemoteDatasource.listWalls();
      return right(wallsList);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> createWall(String wallName) async {
    try {
      return right(
        await feedRemoteDatasource.createWall(wallName),
      );
    } on ServerException catch (e) {
      return left(Failure(message: e.message, fieldErrors: e.fieldErrors));
    }
  }

  @override
  Future<Either<Failure, WallModel>> updateWall(
      int wallId, String wallName) async {
    try {
      final updatedWall = await feedRemoteDatasource.updateWall(
        wallId,
        wallName,
      );
      return right(updatedWall);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, fieldErrors: e.fieldErrors));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWall(int wallId) async {
    try {
      return right(await feedRemoteDatasource.deleteWall(wallId));
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addFeedToWall(int feedId, int wallId) async {
    try {
      return right(
        await feedRemoteDatasource.addFeedToWall(feedId, wallId),
      );
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> removeFeedFromWall(
    int feedId,
    int wallId,
  ) async {
    try {
      return right(
        await feedRemoteDatasource.removeFeedFromWall(feedId, wallId),
      );
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> pinWall(int wallId) async {
    try {
      return right(
        await feedRemoteDatasource.pinWall(wallId),
      );
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> unpinWall(int wallId) async {
    try {
      return right(
        await feedRemoteDatasource.unpinWall(wallId),
      );
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, FeedListModel>> listWallFeeds({
    required int wallId,
    String? searchKey,
    String? searchValue,
    int page = 1,
    int pageSize = ServerConstants.defaultPaginationPageSize,
    String? sortKey,
  }) async {
    try {
      final feedsList = await feedRemoteDatasource.listWallFeeds(
        wallId: wallId,
        searchKey: searchKey,
        searchValue: searchValue,
        page: page,
        pageSize: pageSize,
        sortKey: sortKey,
      );

      return right(feedsList);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveItem(int itemId) async {
    try {
      await feedRemoteDatasource.saveItem(itemId);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> unsaveItem(int itemId) async {
    try {
      await feedRemoteDatasource.unsaveItem(itemId);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, SavedItemListModel>> getSavedItems({
    int page = 1,
    int pageSize = ServerConstants.defaultPaginationPageSize,
    String? title,
    String? sortKey,
  }) async {
    try {
      final savedItems = await feedRemoteDatasource.getSavedItems(
        page: page,
        pageSize: pageSize,
        title: title,
        sortKey: sortKey,
      );
      return right(savedItems);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<bool>>> checkUserSavedItems(
      List<int> itemIds) async {
    try {
      return right(
        await feedRemoteDatasource.checkUserSavedItems(itemIds),
      );
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> likeItem(int itemId) async {
    try {
      await feedRemoteDatasource.likeItem(itemId);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> unlikeItem(int itemId) async {
    try {
      await feedRemoteDatasource.unlikeItem(itemId);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, LikedItemListModel>> getLikedItems({
    int page = 1,
    int pageSize = ServerConstants.defaultPaginationPageSize,
    String? title,
    String? sortKey,
  }) async {
    try {
      final likedItems = await feedRemoteDatasource.getLikedItems(
        page: page,
        pageSize: pageSize,
        title: title,
        sortKey: sortKey,
      );
      return right(likedItems);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<bool>>> checkUserLikedItems(
      List<int> itemIds) async {
    try {
      return right(
        await feedRemoteDatasource.checkUserLikedItems(itemIds),
      );
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, int>> getLikeCount(int itemId) async {
    try {
      return right(
        await feedRemoteDatasource.getLikeCount(itemId),
      );
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
