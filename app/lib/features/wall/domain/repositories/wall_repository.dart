import 'package:app/core/errors/failures.dart';
import 'package:app/features/wall/domain/entities/item_list.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class WallRepository {
  Future<Either<Failure, ItemList>> listWallItems({
    required int wallId,
    String? searchKey,
    String? searchValue,
    int page,
    int pageSize,
    String? sortKey,
  });
}
