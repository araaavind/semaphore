import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/wall/domain/entities/item_list.dart';
import 'package:app/features/wall/domain/repositories/wall_repository.dart';
import 'package:fpdart/fpdart.dart';

class ListWallItemsParams extends PaginationParams {
  final int wallId;

  ListWallItemsParams({
    super.searchKey,
    super.searchValue,
    super.page,
    super.pageSize,
    super.sortKey,
    required this.wallId,
  });
}

class ListWallItems implements Usecase<ItemList, ListWallItemsParams> {
  WallRepository wallRepository;
  ListWallItems(this.wallRepository);

  @override
  Future<Either<Failure, ItemList>> call(ListWallItemsParams params) async {
    return await wallRepository.listWallItems(
      wallId: params.wallId,
      searchKey: params.searchKey,
      searchValue: params.searchValue,
      page: params.page,
      pageSize: params.pageSize,
      sortKey: params.sortKey,
    );
  }
}
