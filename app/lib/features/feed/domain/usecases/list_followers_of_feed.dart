import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/entities/followers_list.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class ListFollowersOfFeedParams extends PaginationParams {
  final int feedId;

  ListFollowersOfFeedParams({
    required this.feedId,
    super.searchKey,
    super.searchValue,
    super.page,
    super.pageSize,
    super.sortKey,
  });
}

class ListFollowersOfFeed
    implements Usecase<FollowersList, ListFollowersOfFeedParams> {
  FeedRepository feedRepository;
  ListFollowersOfFeed(this.feedRepository);

  @override
  Future<Either<Failure, FollowersList>> call(
      ListFollowersOfFeedParams params) async {
    return await feedRepository.listFollowersOfFeed(
      feedId: params.feedId,
      searchKey: params.searchKey,
      searchValue: params.searchValue,
      page: params.page,
      pageSize: params.pageSize,
      sortKey: params.sortKey,
    );
  }
}
