import 'package:equatable/equatable.dart';

class CursorMetadata extends Equatable {
  final int pageSize;
  final String nextCursor;
  final bool hasMore;

  const CursorMetadata({
    required this.pageSize,
    required this.nextCursor,
    required this.hasMore,
  });

  @override
  List<Object> get props => [
        pageSize,
        nextCursor,
        hasMore,
      ];
}
