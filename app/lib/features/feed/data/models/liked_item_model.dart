import 'dart:convert';

import 'package:app/features/feed/data/models/item_model.dart';
import 'package:app/features/feed/domain/entities/liked_item.dart';

class LikedItemModel extends LikedItem {
  const LikedItemModel({
    required super.userId,
    required super.itemId,
    required super.likedAt,
    required super.item,
  });

  LikedItem copyWith({
    int? userId,
    int? itemId,
    DateTime? likedAt,
    ItemModel? item,
  }) {
    return LikedItemModel(
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      likedAt: likedAt ?? this.likedAt,
      item: item ?? this.item,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user_id': userId,
      'item_id': itemId,
      'created_at': likedAt.toIso8601String(),
      'item': (item as ItemModel).toMap(),
    };
  }

  factory LikedItemModel.fromMap(Map<String, dynamic> map) {
    return LikedItemModel(
      userId: map['user_id'] as int,
      itemId: map['item_id'] as int,
      likedAt: DateTime.parse(map['created_at'] as String),
      item: ItemModel.fromMap(map['item'] as Map<String, dynamic>)
          .copyWith(isLiked: true),
    );
  }

  String toJson() => json.encode(toMap());

  factory LikedItemModel.fromJson(String source) =>
      LikedItemModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
