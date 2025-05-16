import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/entities/liked_item_list.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetLikedItemsParams extends PaginationParams {
  GetLikedItemsParams({
    super.searchKey,
    super.searchValue,
    super.page,
    super.pageSize,
    super.sortKey,
  });
}

class GetLikedItems {
  final FeedRepository repository;

  GetLikedItems(this.repository);

  Future<Either<Failure, LikedItemList>> call(
      GetLikedItemsParams params) async {
    return await repository.getLikedItems(
      page: params.page,
      pageSize: params.pageSize,
      title: params.searchValue,
      sortKey: params.sortKey,
    );
  }
}
