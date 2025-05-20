import 'dart:convert';

import 'package:app/core/common/models/cursor_metadata_model.dart';
import 'package:app/features/feed/data/models/item_model.dart';
import 'package:app/features/feed/domain/entities/item_list.dart';

class ItemListModel extends ItemList {
  const ItemListModel({
    required List<ItemModel> items,
    required CursorMetadataModel metadata,
  }) : super(
          items: items,
          metadata: metadata,
        );

  ItemListModel copyWith({
    List<ItemModel>? items,
    CursorMetadataModel? metadata,
  }) {
    return ItemListModel(
      items: items ?? this.items.cast<ItemModel>(),
      metadata: metadata ?? this.metadata as CursorMetadataModel,
    );
  }

  factory ItemListModel.fromMap(Map<String, dynamic> map) {
    return ItemListModel(
      items: (map['items'] as List)
          .map((item) => ItemModel.fromMap(item))
          .toList(),
      metadata: CursorMetadataModel.fromMap(
        map['metadata'] as Map<String, dynamic>,
      ),
    );
  }

  factory ItemListModel.fromJson(String source) =>
      ItemListModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
