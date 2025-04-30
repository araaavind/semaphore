import 'package:app/core/constants/server_constants.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/feed/data/datasources/feed_remote_datasource.dart';
import 'package:app/features/feed/data/models/feed_list_model.dart';
import 'package:app/features/feed/domain/entities/followers_list.dart';
import 'package:app/features/feed/domain/entities/item_list.dart';
import 'package:app/features/feed/domain/entities/wall.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:app/features/feed/presentation/bloc/list_items/list_items_bloc.dart';
import 'package:fpdart/fpdart.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRemoteDatasource feedRemoteDatasource;

  FeedRepositoryImpl(this.feedRemoteDatasource);

  @override
  Future<Either<Failure, FeedListModel>> listAllFeeds({
    String? searchKey,
    String? searchValue,
    int page = 1,
    int pageSize = ServerConstants.defaultPaginationPageSize,
    String? sortKey,
  }) async {
    try {
      final feedsList = await feedRemoteDatasource.listAllFeeds(
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
  Future<Either<Failure, FollowersList>> listFollowersOfFeed({
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
  Future<Either<Failure, ItemList>> listItems({
    required int parentId,
    required ListItemsParentType parentType,
    String? searchKey,
    String? searchValue,
    int page = 1,
    int pageSize = ServerConstants.defaultPaginationPageSize,
    String? sortKey,
  }) async {
    try {
      final itemsList = await feedRemoteDatasource.listItems(
        parentId: parentId,
        parentType: parentType,
        searchKey: searchKey,
        searchValue: searchValue,
        page: page,
        pageSize: pageSize,
        sortKey: sortKey,
      );
      return right(itemsList);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Wall>>> listWalls() async {
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
  Future<Either<Failure, Wall>> updateWall(int wallId, String wallName) async {
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
}
