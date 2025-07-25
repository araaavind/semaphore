import 'dart:convert';

import 'package:app/features/feed/data/models/feed_model.dart';
import 'package:app/features/feed/domain/entities/wall.dart';

class WallModel extends Wall {
  const WallModel({
    required super.id,
    required super.name,
    required super.isPrimary,
    required super.isPinned,
    required super.userId,
    super.feeds,
  });

  WallModel copyWith({
    int? id,
    String? name,
    bool? isPrimary,
    bool? isPinned,
    int? userId,
    List<FeedModel>? feeds,
  }) {
    return WallModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isPrimary: isPrimary ?? this.isPrimary,
      isPinned: isPinned ?? this.isPinned,
      userId: userId ?? this.userId,
      feeds: feeds ?? this.feeds,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'is_primary': isPrimary,
      'is_pinned': isPinned,
      'user_id': userId,
      'feeds': feeds?.map((f) => (f as FeedModel).toMap()).toList(),
    };
  }

  factory WallModel.fromMap(Map<String, dynamic> map) {
    return WallModel(
      id: map['id'] as int,
      name: map['name'] as String,
      isPrimary: map['is_primary'] as bool,
      isPinned: map['is_pinned'] as bool,
      userId: map['user_id'] as int,
      feeds: map['feeds'] != null
          ? (map['feeds'] as List)
              .map((feed) => FeedModel.fromMap(feed))
              .toList()
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory WallModel.fromJson(String source) =>
      WallModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
