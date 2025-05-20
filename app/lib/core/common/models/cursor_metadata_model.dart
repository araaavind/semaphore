import 'dart:convert';

import 'package:app/core/common/entities/cursor_metadata.dart';

class CursorMetadataModel extends CursorMetadata {
  const CursorMetadataModel({
    required super.pageSize,
    required super.nextCursor,
    required super.hasMore,
  });

  CursorMetadataModel copyWith({
    int? pageSize,
    String? nextCursor,
    bool? hasMore,
  }) {
    return CursorMetadataModel(
      pageSize: pageSize ?? this.pageSize,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  factory CursorMetadataModel.fromMap(Map<String, dynamic> map) {
    return CursorMetadataModel(
      pageSize: map['page_size'] as int,
      nextCursor: map['next_cursor'] as String,
      hasMore: map['has_more'] as bool,
    );
  }

  factory CursorMetadataModel.fromJson(String source) =>
      CursorMetadataModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );
}
