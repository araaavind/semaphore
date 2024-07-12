import 'package:app/core/constants/server_constants.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/feed/data/models/feed_list_model.dart';
import 'package:dio/dio.dart';
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
}

class FeedRemoteDatasourceImpl implements FeedRemoteDatasource {
  sp.SemaphoreClient semaphoreClient;

  FeedRemoteDatasourceImpl(this.semaphoreClient);

  @override
  Future<FeedListModel> listAllFeeds({
    String? searchKey,
    String? searchValue,
    int page = ServerConstants.defaultPaginationPage,
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
    } on sp.NetworkException catch (e) {
      if (kDebugMode) {
        print('NetworkException $e.message');
      }
      throw ServerException(e.message!);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Dio exception $e.message');
        print(e.stackTrace);
      }
      throw const ServerException(ServerConstants.internalServerErrorMessage);
    } catch (e) {
      if (kDebugMode) {
        print('Unknown exception $e.toString()');
      }
      throw const ServerException(ServerConstants.internalServerErrorMessage);
    }
  }
}
