import 'dart:convert';

import 'package:app/core/common/entities/paginated_list.dart';

import 'pagination_metadata_model.dart';

class OffsetBasedListModel extends OffsetBasedList {
  const OffsetBasedListModel({
    required super.metadata,
  });

  OffsetBasedListModel copyWith({
    PaginationMetadataModel? metadata,
  }) {
    return OffsetBasedListModel(
      metadata: metadata ?? this.metadata,
    );
  }

  factory OffsetBasedListModel.fromMap(Map<String, dynamic> map) {
    return OffsetBasedListModel(
      metadata: PaginationMetadataModel.fromMap(
        map['metadata'] as Map<String, dynamic>,
      ),
    );
  }

  factory OffsetBasedListModel.fromJson(String source) =>
      OffsetBasedListModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
