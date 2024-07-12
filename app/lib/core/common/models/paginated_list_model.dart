import 'dart:convert';

import 'pagination_metadata_model.dart';

class PaginatedListModel {
  final PaginationMetadataModel metadata;

  PaginatedListModel({
    required this.metadata,
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
