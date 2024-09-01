import 'package:app/core/constants/constants.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/feed/data/models/feed_list_model.dart';
import 'package:app/features/feed/data/models/followers_list_model.dart';
import 'package:app/features/feed/data/models/item_list_model.dart';
import 'package:app/features/feed/data/models/wall_model.dart';
import 'package:app/features/feed/presentation/bloc/list_items/list_items_bloc.dart';
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

  Future<int> addAndFollowFeed(String feedUrl);

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

  Future<ItemListModel> listItems({
    required int parentId,
    required ListItemsParentType parentType,
    String? searchKey,
    String? searchValue,
    int page,
    int pageSize,
    String? sortKey,
  });

  Future<List<WallModel>> listWalls();

  Future<void> createWall(String wallName);

  Future<void> addFeedToWall(int feedId, int wallId);

  Future<void> removeFeedFromWall(int feedId, int wallId);
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
  Future<int> addAndFollowFeed(String feedUrl) async {
    try {
      final response = await semaphoreClient.dio.post(
        '/feeds',
        data: {
          'feed_link': feedUrl,
        },
      );
      return response.data['feed_id'] as int;
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

  @override
  Future<ItemListModel> listItems({
    required int parentId,
    required ListItemsParentType parentType,
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
      String url;
      if (parentType == ListItemsParentType.wall) {
        url = '/walls/$parentId/items';
      } else {
        url = '/feeds/$parentId/items';
      }
      final response = await semaphoreClient.dio.get(
        url,
        queryParameters: queryParams,
      );
      return ItemListModel.fromMap(response.data);
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
  Future<List<WallModel>> listWalls() async {
    try {
      final response = await semaphoreClient.dio.get('/me/walls');
      return (response.data['walls'] as List)
          .map((wall) => WallModel.fromMap(wall))
          .toList();
    } on sp.SemaphoreException catch (e) {
      if (e.responseStatusCode != null && e.responseStatusCode == 404) {
        throw const ServerException('No walls found');
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
  Future<void> createWall(String wallName) async {
    try {
      await semaphoreClient.dio.post('/walls', data: {'name': wallName});
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
  Future<void> addFeedToWall(int feedId, int wallId) async {
    try {
      await semaphoreClient.dio.put(
        '/walls/$wallId/feeds/$feedId',
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
  Future<void> removeFeedFromWall(int feedId, int wallId) async {
    try {
      await semaphoreClient.dio.delete(
        '/walls/$wallId/feeds/$feedId',
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
}
