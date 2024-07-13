import 'dart:convert';

import 'package:app/core/common/entities/paginated_list.dart';

import 'pagination_metadata_model.dart';

class PaginatedListModel extends PaginatedList {
  const PaginatedListModel({
    required super.metadata,
  });

  PaginatedListModel copyWith({
    PaginationMetadataModel? metadata,
  }) {
    return PaginatedListModel(
      metadata: metadata ?? this.metadata,
    );
  }

  factory PaginatedListModel.fromMap(Map<String, dynamic> map) {
    return PaginatedListModel(
      metadata: PaginationMetadataModel.fromMap(
        map['metadata'] as Map<String, dynamic>,
      ),
    );
  }

  factory PaginatedListModel.fromJson(String source) =>
      PaginatedListModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
