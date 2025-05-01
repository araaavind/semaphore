import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/entities/feed_list.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

enum ListFeedsType { all, followed, wall }

class ListFeedsParams extends PaginationParams {
  final ListFeedsType type;
  final int? wallId;

  ListFeedsParams({
    this.wallId,
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
    if (params.type == ListFeedsType.wall) {
      if (params.wallId == null) {
        return left(const Failure(message: 'wallId is required'));
      }
      return await feedRepository.listWallFeeds(
        wallId: params.wallId!,
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
