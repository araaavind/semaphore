import 'dart:convert';

import 'package:app/features/feed/domain/entities/feed.dart';

class FeedModel extends Feed {
  const FeedModel({
    required super.id,
    required super.title,
    required super.link,
    required super.feedLink,
    super.description,
    super.imageUrl,
    super.pubDate,
    super.pubUpdated,
    super.feedType,
    super.language,
    super.followersCount,
  });

  FeedModel copyWith({
    int? id,
    String? title,
    String? description,
    String? link,
    String? feedLink,
    String? imageUrl,
    DateTime? pubDate,
    DateTime? pubUpdated,
    FeedType? feedType,
    String? language,
    int? followersCount,
  }) {
    return FeedModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      feedLink: feedLink ?? this.feedLink,
      imageUrl: imageUrl ?? this.imageUrl,
      pubDate: pubDate ?? this.pubDate,
      pubUpdated: pubUpdated ?? this.pubUpdated,
      feedType: feedType ?? this.feedType,
      language: language ?? this.language,
      followersCount: followersCount ?? this.followersCount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'link': link,
      'feed_link': feedLink,
      'image_url': imageUrl,
      'pub_date': pubDate?.toIso8601String(),
      'pub_updated': pubUpdated?.toIso8601String(),
      'feed_type': feedType?.name,
      'language': language,
      'followers_count': followersCount,
    };
  }

  factory FeedModel.fromMap(Map<String, dynamic> map) {
    return FeedModel(
      id: map['id'] as int,
      title: map['title'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      link: map['link'] as String,
      feedLink: map['feed_link'] as String,
      imageUrl: map['image_url'] != null ? map['image_url'] as String : null,
      pubDate: map['pub_date'] != null
          ? DateTime.parse(map['pub_date'] as String)
          : null,
      pubUpdated: map['pub_updated'] != null
          ? DateTime.parse(map['pub_updated'] as String)
          : null,
      feedType: map['feed_type'] != null
          ? FeedType.fromString(map['feed_type'] as String)
          : null,
      language: map['language'] != null ? map['language'] as String : null,
      followersCount:
          map['followers_count'] != null ? map['followers_count'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory FeedModel.fromJson(String source) =>
      FeedModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
