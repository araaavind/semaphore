import 'package:app/core/errors/failures.dart';
import 'package:app/features/feed/domain/entities/item_list.dart';
import 'package:app/features/feed/domain/entities/wall.dart';
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

  Future<Either<Failure, List<Wall>>> listWalls();
}
