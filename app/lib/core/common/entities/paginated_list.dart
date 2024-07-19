import 'package:app/core/constants/constants.dart';
import 'package:equatable/equatable.dart';

import 'pagination_metadata.dart';

class PaginatedList extends Equatable {
  final PaginationMetadata metadata;

  const PaginatedList({
    this.metadata = const PaginationMetadata(
      currentPage: ServerConstants.defaultPaginationPage,
      pageSize: ServerConstants.defaultPaginationPageSize,
      firstPage: 1,
      lastPage: 1,
      totalRecords: 0,
    ),
  });

  @override
  List<Object> get props => [metadata];
}
