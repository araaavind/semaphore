import 'package:app/core/constants/server_constants.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/feed/data/datasources/feed_remote_datasource.dart';
import 'package:app/features/feed/data/models/feed_list_model.dart';
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
}
