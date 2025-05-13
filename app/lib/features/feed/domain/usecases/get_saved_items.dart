import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/entities/saved_item_list.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetSavedItemsParams extends PaginationParams {
  GetSavedItemsParams({
    super.searchKey,
    super.searchValue,
    super.page,
    super.pageSize,
    super.sortKey,
  });
}

class GetSavedItems {
  final FeedRepository repository;

  GetSavedItems(this.repository);

  Future<Either<Failure, SavedItemList>> call(
      GetSavedItemsParams params) async {
    return await repository.getSavedItems(
      page: params.page,
      pageSize: params.pageSize,
      title: params.searchValue,
      sortKey: params.sortKey,
    );
  }
}
