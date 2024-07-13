import 'package:equatable/equatable.dart';

import 'pagination_metadata.dart';

class PaginatedList extends Equatable {
  final PaginationMetadata metadata;

  const PaginatedList({
    required this.metadata,
  });

  @override
  List<Object> get props => [metadata];
}
