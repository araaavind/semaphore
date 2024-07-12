import 'package:app/core/constants/server_constants.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/entities/feed_list.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class ListFeedParams {
  final String? searchKey;
  final String? searchValue;
  final int page;
  final int pageSize;
  final String? sortKey;

  ListFeedParams({
    this.searchKey,
    this.searchValue,
    this.page = ServerConstants.defaultPaginationPage,
    this.pageSize = ServerConstants.defaultPaginationPageSize,
    this.sortKey,
  });
}

class ListFeeds implements Usecase<FeedList, ListFeedParams> {
  FeedRepository feedRepository;
  ListFeeds(this.feedRepository);

  @override
  Future<Either<Failure, FeedList>> call(ListFeedParams params) async {
    return await feedRepository.listAllFeeds(
      searchKey: params.searchKey,
      searchValue: params.searchValue,
      page: params.page,
      pageSize: params.pageSize,
      sortKey: params.sortKey,
    );
  }
}
