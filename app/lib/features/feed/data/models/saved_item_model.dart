import 'dart:convert';

import 'package:app/features/feed/data/models/item_model.dart';
import 'package:app/features/feed/domain/entities/saved_item.dart';

class SavedItemModel extends SavedItem {
  const SavedItemModel({
    required super.userId,
    required super.itemId,
    required super.savedAt,
    required super.item,
  });

  SavedItem copyWith({
    int? userId,
    int? itemId,
    DateTime? savedAt,
    ItemModel? item,
  }) {
    return SavedItemModel(
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      savedAt: savedAt ?? this.savedAt,
      item: item ?? this.item,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user_id': userId,
      'item_id': itemId,
      'created_at': savedAt.toIso8601String(),
      'item': (item as ItemModel).toMap(),
    };
  }

  factory SavedItemModel.fromMap(Map<String, dynamic> map) {
    return SavedItemModel(
      userId: map['user_id'] as int,
      itemId: map['item_id'] as int,
      savedAt: DateTime.parse(map['created_at'] as String),
      item: ItemModel.fromMap(map['item'] as Map<String, dynamic>)
          .copyWith(isSaved: true),
    );
  }

  String toJson() => json.encode(toMap());

  factory SavedItemModel.fromJson(String source) =>
      SavedItemModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
