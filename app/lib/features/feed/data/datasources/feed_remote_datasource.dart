import 'package:app/core/constants/constants.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/feed/data/models/feed_list_model.dart';
import 'package:app/features/feed/data/models/followers_list_model.dart';
import 'package:flutter/foundation.dart';
import 'package:smphr_sdk/smphr_sdk.dart' as sp;

abstract interface class FeedRemoteDatasource {
  Future<FeedListModel> listAllFeeds({
    String? searchKey,
    String? searchValue,
    int page,
    int pageSize,
    String? sortKey,
  });

  Future<void> addAndFollowFeed(String feedUrl);

  Future<void> followFeed(int feedId);

  Future<void> unfollowFeed(int feedId);

  Future<FeedListModel> listFeedsFollowedByCurrentUser({
    String? searchKey,
    String? searchValue,
    int page,
    int pageSize,
    String? sortKey,
  });

  Future<FollowersListModel> listFollowersOfFeed({
    required int feedId,
    String? searchKey,
    String? searchValue,
    int page,
    int pageSize,
    String? sortKey,
  });

  Future<List<bool>> checkUserFollowsFeeds(List<int> feedIds);
}

class FeedRemoteDatasourceImpl implements FeedRemoteDatasource {
  sp.SemaphoreClient semaphoreClient;

  FeedRemoteDatasourceImpl(this.semaphoreClient);

  @override
  Future<FeedListModel> listAllFeeds({
    String? searchKey,
    String? searchValue,
    int page = 1,
    int pageSize = ServerConstants.defaultPaginationPageSize,
    String? sortKey,
  }) async {
    try {
      Map<String, dynamic>? queryParams = {'page': page, 'page_size': pageSize};
      if (searchKey != null && searchValue != null) {
        queryParams[searchKey] = searchValue;
      }
      if (sortKey != null) {
        queryParams['sort'] = sortKey;
      }
      final response = await semaphoreClient.dio.get(
        '/feeds',
        queryParameters: queryParams,
      );
      return FeedListModel.fromMap(response.data);
    } on sp.SemaphoreException catch (e) {
      throw ServerException(e.message!);
    } on sp.InternalException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      if (kDebugMode) {
        print('Unknown exception $e.toString()');
      }
      throw const ServerException(TextConstants.internalServerErrorMessage);
    }
  }

  @override
  Future<void> addAndFollowFeed(String feedUrl) async {
    try {
      await semaphoreClient.dio.post(
        '/feeds',
        data: {
          'feed_link': feedUrl,
        },
      );
      return;
    } on sp.SemaphoreException catch (e) {
      if (e.subType == sp.SemaphoreExceptionSubType.invalidField &&
          e.fieldErrors != null &&
          e.fieldErrors!.isNotEmpty) {
        throw ServerException(e.message!, fieldErrors: e.fieldErrors);
      }
      throw ServerException(e.message!);
    } on sp.InternalException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      if (kDebugMode) {
        print('Unknown exception $e.toString()');
      }
      throw const ServerException(TextConstants.internalServerErrorMessage);
    }
  }

  @override
  Future<void> followFeed(int feedId) async {
    try {
      await semaphoreClient.dio.put(
        '/feeds/$feedId/followers',
      );
      return;
    } on sp.SemaphoreException catch (e) {
      throw ServerException(e.message!);
    } on sp.InternalException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      if (kDebugMode) {
        print('Unknown exception $e.toString()');
      }
      throw const ServerException(TextConstants.internalServerErrorMessage);
    }
  }

  @override
  Future<void> unfollowFeed(int feedId) async {
    try {
      await semaphoreClient.dio.delete(
        '/feeds/$feedId/followers',
      );
      return;
    } on sp.SemaphoreException catch (e) {
      throw ServerException(e.message!);
    } on sp.InternalException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      if (kDebugMode) {
        print('Unknown exception $e.toString()');
      }
      throw const ServerException(TextConstants.internalServerErrorMessage);
    }
  }

  @override
  Future<FeedListModel> listFeedsFollowedByCurrentUser({
    String? searchKey,
    String? searchValue,
    int page = 1,
    int pageSize = ServerConstants.defaultPaginationPageSize,
    String? sortKey,
  }) async {
    try {
      Map<String, dynamic>? queryParams = {'page': page, 'page_size': pageSize};
      if (searchKey != null && searchValue != null) {
        queryParams[searchKey] = searchValue;
      }
      if (sortKey != null) {
        queryParams['sort'] = sortKey;
      }
      final response = await semaphoreClient.dio.get(
        '/me/feeds',
        queryParameters: queryParams,
      );
      return FeedListModel.fromMap(response.data);
    } on sp.SemaphoreException catch (e) {
      throw ServerException(e.message!);
    } on sp.InternalException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      if (kDebugMode) {
        print('Unknown exception $e.toString()');
      }
      throw const ServerException(TextConstants.internalServerErrorMessage);
    }
  }

  @override
  Future<List<bool>> checkUserFollowsFeeds(List<int> feedIds) async {
    try {
      Map<String, String> queryParams = {'ids': feedIds.join(',')};
      final response = await semaphoreClient.dio.get(
        '/me/feeds/contains',
        queryParameters: queryParams,
      );
      return (response.data['follows'] as List)
          .map((isFollowed) => isFollowed as bool)
          .toList();
    } on sp.SemaphoreException catch (e) {
      throw ServerException(e.message!);
    } on sp.InternalException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      if (kDebugMode) {
        print('Unknown exception $e.toString()');
      }
      throw const ServerException(TextConstants.internalServerErrorMessage);
    }
  }

  @override
  Future<FollowersListModel> listFollowersOfFeed({
    required int feedId,
    String? searchKey,
    String? searchValue,
    int page = 1,
    int pageSize = ServerConstants.defaultPaginationPageSize,
    String? sortKey,
  }) async {
    try {
      Map<String, dynamic>? queryParams = {'page': page, 'page_size': pageSize};
      if (searchKey != null && searchValue != null) {
        queryParams[searchKey] = searchValue;
      }
      if (sortKey != null) {
        queryParams['sort'] = sortKey;
      }
      final response = await semaphoreClient.dio.get(
        '/feeds/$feedId/followers',
        queryParameters: queryParams,
      );
      return FollowersListModel.fromMap(response.data);
    } on sp.SemaphoreException catch (e) {
      throw ServerException(e.message!);
    } on sp.InternalException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      if (kDebugMode) {
        print('Unknown exception $e.toString()');
      }
      throw const ServerException(TextConstants.internalServerErrorMessage);
    }
  }
}
