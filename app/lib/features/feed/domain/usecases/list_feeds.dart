import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/entities/feed_list.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

enum ListFeedsType { all, followed }

class ListFeedsParams extends PaginationParams {
  final ListFeedsType type;

  ListFeedsParams({
    super.searchKey,
    super.searchValue,
    super.page,
    super.pageSize,
    super.sortKey,
    required this.type,
  });
}

class ListFeeds implements Usecase<FeedList, ListFeedsParams> {
  FeedRepository feedRepository;
  ListFeeds(this.feedRepository);

  @override
  Future<Either<Failure, FeedList>> call(ListFeedsParams params) async {
    if (params.type == ListFeedsType.followed) {
      return await feedRepository.listFeedsFollowedByCurrentUser(
        searchKey: params.searchKey,
        searchValue: params.searchValue,
        page: params.page,
        pageSize: params.pageSize,
        sortKey: params.sortKey,
      );
    }
    return await feedRepository.listAllFeeds(
      searchKey: params.searchKey,
      searchValue: params.searchValue,
      page: params.page,
      pageSize: params.pageSize,
      sortKey: params.sortKey,
    );
  }
}
