import 'dart:convert';

import 'package:app/core/common/models/pagination_metadata_model.dart';
import 'package:app/features/feed/data/models/liked_item_model.dart';
import 'package:app/features/feed/domain/entities/liked_item_list.dart';

class LikedItemListModel extends LikedItemList {
  const LikedItemListModel({
    required List<LikedItemModel> likedItems,
    required PaginationMetadataModel metadata,
  }) : super(
          likedItems: likedItems,
          metadata: metadata,
        );

  LikedItemListModel copyWith({
    List<LikedItemModel>? likedItems,
    PaginationMetadataModel? metadata,
  }) {
    return LikedItemListModel(
      likedItems: likedItems ?? this.likedItems.cast<LikedItemModel>(),
      metadata: metadata ?? this.metadata as PaginationMetadataModel,
    );
  }

  factory LikedItemListModel.fromMap(Map<String, dynamic> map) {
    return LikedItemListModel(
      likedItems: (map['liked_items'] as List)
          .map((likedItem) => LikedItemModel.fromMap(likedItem))
          .toList(),
      metadata: PaginationMetadataModel.fromMap(
        map['metadata'] as Map<String, dynamic>,
      ),
    );
  }

  factory LikedItemListModel.fromJson(String source) =>
      LikedItemListModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
