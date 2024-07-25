import 'package:app/core/constants/server_constants.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/feed/data/datasources/feed_remote_datasource.dart';
import 'package:app/features/feed/data/models/feed_list_model.dart';
import 'package:app/features/feed/data/models/feed_model.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
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
      final results = await Future.wait([
        feedRemoteDatasource.listAllFeeds(
          searchKey: searchKey,
          searchValue: searchValue,
          page: page,
          pageSize: pageSize,
          sortKey: sortKey,
        ),
        feedRemoteDatasource.listFeedsFollowedByCurrentUser(
          searchKey: searchKey,
          searchValue: searchValue,
          page: page,
          pageSize: pageSize,
          sortKey: sortKey,
        ),
      ]);

      FeedListModel feedsList = results[0];
      final followedFeedIds = results[1].feeds.map((e) => e.id).toSet();

      List<FeedModel> updatedFeeds = (feedsList.feeds as List<FeedModel>).map(
        (feed) {
          if (followedFeedIds.contains(feed.id)) {
            return feed.copyWith(
              isFollowed: true,
            );
          }
          return feed;
        },
      ).toList();

      return right(
        feedsList.copyWith(
          feeds: updatedFeeds,
        ),
      );
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
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
}
