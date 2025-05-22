import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/entities/item_list.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:app/features/feed/presentation/bloc/list_items/list_items_bloc.dart';
import 'package:fpdart/fpdart.dart';

class ListItemsParams extends CursorParams {
  final int parentId;
  final ListItemsParentType parentType;

  ListItemsParams({
    super.searchKey,
    super.searchValue,
    super.after,
    super.pageSize,
    super.sortMode,
    super.sessionId,
    required this.parentId,
    required this.parentType,
  });
}

class ListItems implements Usecase<ItemList, ListItemsParams> {
  FeedRepository feedRepository;
  ListItems(this.feedRepository);

  @override
  Future<Either<Failure, ItemList>> call(ListItemsParams params) async {
    return await feedRepository.listItems(
      parentId: params.parentId,
      parentType: params.parentType,
      searchKey: params.searchKey,
      searchValue: params.searchValue,
      after: params.after,
      pageSize: params.pageSize,
      sortMode: params.sortMode,
      sessionId: params.sessionId,
    );
  }
}
