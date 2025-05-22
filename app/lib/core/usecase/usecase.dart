import 'package:app/core/constants/server_constants.dart';
import 'package:app/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class Usecase<SuccessType, ParamsType> {
  Future<Either<Failure, SuccessType>> call(ParamsType params);
}

class NoParams {}

class PaginationParams {
  final String? searchKey;
  final String? searchValue;
  final int page;
  final int pageSize;
  final String? sortKey;

  PaginationParams({
    this.searchKey,
    this.searchValue,
    this.page = 1,
    this.pageSize = ServerConstants.defaultPaginationPageSize,
    this.sortKey,
  });
}

class CursorParams {
  final String? searchKey;
  final String? searchValue;
  final String after;
  final int pageSize;
  final String? sortMode;
  final String? sessionId;

  CursorParams({
    this.searchKey,
    this.searchValue,
    this.after = '',
    this.pageSize = ServerConstants.defaultPaginationPageSize,
    this.sortMode,
    this.sessionId,
  });
}
