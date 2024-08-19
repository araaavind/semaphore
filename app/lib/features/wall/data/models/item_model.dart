import 'dart:convert';

import 'package:app/features/feed/data/models/feed_model.dart';
import 'package:app/features/wall/domain/entities/item.dart';

class ItemModel extends Item {
  const ItemModel({
    required super.id,
    required super.title,
    required super.link,
    required super.guid,
    super.description,
    super.pubDate,
    super.pubUpdated,
    super.imageUrl,
    super.feed,
  });

  ItemModel copyWith({
    int? id,
    String? title,
    String? description,
    String? link,
    String? guid,
    DateTime? pubDate,
    DateTime? pubUpdated,
    String? imageUrl,
    FeedModel? feed,
  }) {
    return ItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      guid: guid ?? this.guid,
      pubDate: pubDate ?? this.pubDate,
      pubUpdated: pubUpdated ?? this.pubUpdated,
      imageUrl: imageUrl ?? this.imageUrl,
      feed: feed ?? this.feed,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'link': link,
      'guid': guid,
      'pub_date': pubDate?.toIso8601String(),
      'pub_updated': pubUpdated?.toIso8601String(),
      'image_url': imageUrl,
      'feed': (feed as FeedModel).toMap(),
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as int,
      title: map['title'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      link: map['link'] as String,
      guid: map['guid'] as String,
      pubDate: map['pub_date'] != null
          ? DateTime.parse(map['pub_date'] as String)
          : null,
      pubUpdated: map['pub_updated'] != null
          ? DateTime.parse(map['pub_updated'] as String)
          : null,
      imageUrl: map['image_url'] != null ? map['image_url'] as String : null,
      feed: map['feed'] != null
          ? FeedModel.fromMap(map['feed'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemModel.fromJson(String source) =>
      ItemModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
