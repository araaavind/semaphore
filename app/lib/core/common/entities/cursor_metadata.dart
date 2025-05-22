import 'package:equatable/equatable.dart';

class CursorMetadata extends Equatable {
  final int pageSize;
  final String? sessionId;
  final String nextCursor;
  final bool hasMore;

  const CursorMetadata({
    required this.pageSize,
    this.sessionId,
    required this.nextCursor,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [
        pageSize,
        sessionId,
        nextCursor,
        hasMore,
      ];
}
