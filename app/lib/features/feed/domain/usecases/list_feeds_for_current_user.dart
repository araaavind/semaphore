import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/entities/feed_list.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class ListFeedsForCurrentUser implements Usecase<FeedList, PaginationParams> {
  FeedRepository feedRepository;
  ListFeedsForCurrentUser(this.feedRepository);

  @override
  Future<Either<Failure, FeedList>> call(PaginationParams params) async {
    return await feedRepository.listAllFeeds(
      searchKey: params.searchKey,
      searchValue: params.searchValue,
      page: params.page,
      pageSize: params.pageSize,
      sortKey: params.sortKey,
    );
  }
}
