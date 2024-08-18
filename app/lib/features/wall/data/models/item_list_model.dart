import 'dart:convert';

import 'package:app/core/common/models/pagination_metadata_model.dart';
import 'package:app/features/wall/data/models/item_model.dart';
import 'package:app/features/wall/domain/entities/item_list.dart';

class ItemListModel extends ItemList {
  const ItemListModel({
    required List<ItemModel> items,
    required PaginationMetadataModel metadata,
  }) : super(
          items: items,
          metadata: metadata,
        );

  ItemListModel copyWith({
    List<ItemModel>? items,
    PaginationMetadataModel? metadata,
  }) {
    return ItemListModel(
      items: items ?? this.items.cast<ItemModel>(),
      metadata: metadata ?? this.metadata as PaginationMetadataModel,
    );
  }

  factory ItemListModel.fromMap(Map<String, dynamic> map) {
    return ItemListModel(
      items: (map['items'] as List)
          .map((item) => ItemModel.fromMap(item))
          .toList(),
      metadata: PaginationMetadataModel.fromMap(
        map['metadata'] as Map<String, dynamic>,
      ),
    );
  }

  factory ItemListModel.fromJson(String source) =>
      ItemListModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
