import 'package:app/core/constants/constants.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/feed/data/models/feed_list_model.dart';
import 'package:app/features/feed/data/models/followers_list_model.dart';
import 'package:app/features/feed/data/models/item_list_model.dart';
import 'package:app/features/feed/data/models/liked_item_list_model.dart';
import 'package:app/features/feed/data/models/saved_item_list_model.dart';
import 'package:app/features/feed/data/models/topic_model.dart';
import 'package:app/features/feed/data/models/wall_model.dart';
import 'package:app/features/feed/presentation/bloc/list_items/list_items_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:smphr_sdk/smphr_sdk.dart' as sp;

abstract interface class FeedRemoteDatasource {
  Future<List<TopicModel>> listTopics();

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
    String after,
    int pageSize,
    String? sortMode,
    String? sessionId,
  });

  Future<List<WallModel>> listWalls();

  Future<void> createWall(String wallName);

  Future<WallModel> updateWall(int wallId, String wallName);

  Future<void> deleteWall(int wallId);

  Future<void> addFeedToWall(int feedId, int wallId);

  Future<void> removeFeedFromWall(int feedId, int wallId);

  Future<void> pinWall(int wallId);

  Future<void> unpinWall(int wallId);

  Future<FeedListModel> listWallFeeds({
    required int wallId,
    String? searchKey,
    String? searchValue,
    int page,
    int pageSize,
    String? sortKey,
  });

  Future<void> saveItem(int itemId);
  Future<void> unsaveItem(int itemId);
  Future<SavedItemListModel> getSavedItems({
    int page,
    int pageSize,
    String? title,
    String? sortKey,
  });

  Future<List<bool>> checkUserSavedItems(List<int> itemIds);

  Future<void> likeItem(int itemId);
  Future<void> unlikeItem(int itemId);
  Future<LikedItemListModel> getLikedItems({
    int page,
    int pageSize,
    String? title,
    String? sortKey,
  });
  Future<List<bool>> checkUserLikedItems(List<int> itemIds);
  Future<int> getLikeCount(int itemId);
}

class FeedRemoteDatasourceImpl implements FeedRemoteDatasource {
  sp.SemaphoreClient semaphoreClient;

  FeedRemoteDatasourceImpl(this.semaphoreClient);

  @override
  Future<List<TopicModel>> listTopics() async {
    try {
      final response = await semaphoreClient.dio.get('/topics');
      return (response.data['topics'] as List)
          .map((topic) => TopicModel.fromMap(topic))
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
      if (e.subType == sp.SemaphoreExceptionSubType.invalidField) {
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
    String after = '',
    int pageSize = ServerConstants.defaultPaginationPageSize,
    String? sortMode,
    String? sessionId,
  }) async {
    try {
      Map<String, dynamic>? queryParams = {
        'after': after,
        'page_size': pageSize
      };
      if (searchKey != null && searchValue != null) {
        queryParams[searchKey] = searchValue;
      }
      if (sortMode != null) {
        queryParams['sort_mode'] = sortMode;
      }
      if (sessionId != null) {
        queryParams['session_id'] = sessionId;
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
      if (e.subType == sp.SemaphoreExceptionSubType.invalidField) {
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
  Future<WallModel> updateWall(int wallId, String wallName) async {
    try {
      final response = await semaphoreClient.dio
          .put('/walls/$wallId', data: {'name': wallName});
      return WallModel.fromMap(response.data['wall']);
    } on sp.SemaphoreException catch (e) {
      if (e.subType == sp.SemaphoreExceptionSubType.invalidField) {
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
  Future<void> deleteWall(int wallId) async {
    try {
      await semaphoreClient.dio.delete('/walls/$wallId');
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

  @override
  Future<void> pinWall(int wallId) async {
    try {
      await semaphoreClient.dio.put('/walls/$wallId/pin');
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
  Future<void> unpinWall(int wallId) async {
    try {
      await semaphoreClient.dio.put('/walls/$wallId/unpin');
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
  Future<FeedListModel> listWallFeeds({
    required int wallId,
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
        '/walls/$wallId/feeds',
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
  Future<void> saveItem(int itemId) async {
    try {
      await semaphoreClient.dio.put(
        '/items/$itemId/save',
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
  Future<void> unsaveItem(int itemId) async {
    try {
      await semaphoreClient.dio.put(
        '/items/$itemId/unsave',
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
  Future<SavedItemListModel> getSavedItems({
    int page = 1,
    int pageSize = ServerConstants.defaultPaginationPageSize,
    String? title,
    String? sortKey,
  }) async {
    try {
      Map<String, dynamic> queryParams = {'page': page, 'page_size': pageSize};
      if (title != null && title.isNotEmpty) {
        queryParams['title'] = title;
      }
      if (sortKey != null) {
        queryParams['sort'] = sortKey;
      }

      final response = await semaphoreClient.dio.get(
        '/me/items/saved',
        queryParameters: queryParams,
      );
      return SavedItemListModel.fromMap(response.data);
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
  Future<List<bool>> checkUserSavedItems(List<int> itemIds) async {
    try {
      Map<String, String> queryParams = {'ids': itemIds.join(',')};
      final response = await semaphoreClient.dio.get(
        '/me/items/saved/contains',
        queryParameters: queryParams,
      );
      return (response.data['saved'] as List)
          .map((isSaved) => isSaved as bool)
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
  Future<void> likeItem(int itemId) async {
    try {
      await semaphoreClient.dio.put(
        '/items/$itemId/like',
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
  Future<void> unlikeItem(int itemId) async {
    try {
      await semaphoreClient.dio.put(
        '/items/$itemId/unlike',
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
  Future<LikedItemListModel> getLikedItems({
    int page = 1,
    int pageSize = ServerConstants.defaultPaginationPageSize,
    String? title,
    String? sortKey,
  }) async {
    try {
      Map<String, dynamic> queryParams = {'page': page, 'page_size': pageSize};
      if (title != null && title.isNotEmpty) {
        queryParams['title'] = title;
      }
      if (sortKey != null) {
        queryParams['sort'] = sortKey;
      }

      final response = await semaphoreClient.dio.get(
        '/me/items/liked',
        queryParameters: queryParams,
      );
      return LikedItemListModel.fromMap(response.data);
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
  Future<List<bool>> checkUserLikedItems(List<int> itemIds) async {
    try {
      Map<String, String> queryParams = {'ids': itemIds.join(',')};
      final response = await semaphoreClient.dio.get(
        '/me/items/liked/contains',
        queryParameters: queryParams,
      );
      return (response.data['liked'] as List)
          .map((isLiked) => isLiked as bool)
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
  Future<int> getLikeCount(int itemId) async {
    try {
      final response = await semaphoreClient.dio.get(
        '/items/$itemId/like_count',
      );
      return response.data['like_count'] as int;
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
