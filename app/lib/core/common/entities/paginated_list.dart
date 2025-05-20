import 'package:app/core/common/entities/cursor_metadata.dart';
import 'package:app/core/constants/constants.dart';
import 'package:equatable/equatable.dart';

import 'pagination_metadata.dart';

abstract class PaginatedList<T> extends Equatable {
  final T metadata;

  const PaginatedList({
    required this.metadata,
  });

  @override
  List<Object> get props => [metadata as Object];
}

class OffsetBasedList extends PaginatedList<PaginationMetadata> {
  const OffsetBasedList({
    super.metadata = const PaginationMetadata(
      currentPage: 1,
      pageSize: ServerConstants.defaultPaginationPageSize,
      firstPage: 1,
      lastPage: 1,
      totalRecords: 0,
    ),
  });
}

class CursorBasedList extends PaginatedList<CursorMetadata> {
  const CursorBasedList({
    super.metadata = const CursorMetadata(
      pageSize: ServerConstants.defaultPaginationPageSize,
      nextCursor: '',
      hasMore: false,
    ),
  });
}
