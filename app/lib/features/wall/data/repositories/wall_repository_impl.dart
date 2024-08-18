import 'package:app/core/constants/constants.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/wall/data/datasources/wall_remote_datasource.dart';
import 'package:app/features/wall/domain/entities/item_list.dart';
import 'package:app/features/wall/domain/entities/wall.dart';
import 'package:app/features/wall/domain/repositories/wall_repository.dart';
import 'package:fpdart/fpdart.dart';

class WallRepositoryImpl implements WallRepository {
  WallRemoteDatasource wallRemoteDatasource;

  WallRepositoryImpl(this.wallRemoteDatasource);

  @override
  Future<Either<Failure, ItemList>> listWallItems({
    required int wallId,
    String? searchKey,
    String? searchValue,
    int page = 1,
    int pageSize = ServerConstants.defaultPaginationPageSize,
    String? sortKey,
  }) async {
    try {
      final itemsList = await wallRemoteDatasource.listWallItems(
        wallId: wallId,
        searchKey: searchKey,
        searchValue: searchValue,
        page: page,
        pageSize: pageSize,
        sortKey: sortKey,
      );
      return right(itemsList);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Wall>>> listWalls() async {
    try {
      final wallsList = await wallRemoteDatasource.listWalls();
      return right(wallsList);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
