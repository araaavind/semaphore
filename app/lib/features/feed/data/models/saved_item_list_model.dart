import 'dart:convert';

import 'package:app/core/common/models/pagination_metadata_model.dart';
import 'package:app/features/feed/data/models/saved_item_model.dart';
import 'package:app/features/feed/domain/entities/saved_item_list.dart';

class SavedItemListModel extends SavedItemList {
  const SavedItemListModel({
    required List<SavedItemModel> savedItems,
    required PaginationMetadataModel metadata,
  }) : super(
          savedItems: savedItems,
          metadata: metadata,
        );

  SavedItemListModel copyWith({
    List<SavedItemModel>? savedItems,
    PaginationMetadataModel? metadata,
  }) {
    return SavedItemListModel(
      savedItems: savedItems ?? this.savedItems.cast<SavedItemModel>(),
      metadata: metadata ?? this.metadata as PaginationMetadataModel,
    );
  }

  factory SavedItemListModel.fromMap(Map<String, dynamic> map) {
    return SavedItemListModel(
      savedItems: (map['saved_items'] as List)
          .map((savedItem) => SavedItemModel.fromMap(savedItem))
          .toList(),
      metadata: PaginationMetadataModel.fromMap(
        map['metadata'] as Map<String, dynamic>,
      ),
    );
  }

  factory SavedItemListModel.fromJson(String source) =>
      SavedItemListModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
