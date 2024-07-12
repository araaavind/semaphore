import 'dart:convert';

import 'package:app/features/feed/domain/entities/feed.dart';

class FeedModel extends Feed {
  FeedModel({
    required super.id,
    required super.title,
    required super.link,
    required super.feedLink,
    super.description,
    super.pubDate,
    super.pubUpdated,
    super.feedtype,
    super.language,
  });

  FeedModel copyWith({
    int? id,
    String? title,
    String? description,
    String? link,
    String? feedLink,
    DateTime? pubDate,
    DateTime? pubUpdated,
    FeedType? feedtype,
    String? language,
  }) {
    return FeedModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      feedLink: feedLink ?? this.feedLink,
      pubDate: pubDate ?? this.pubDate,
      pubUpdated: pubUpdated ?? this.pubUpdated,
      feedtype: feedtype ?? this.feedtype,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'link': link,
      'feed_link': feedLink,
      'pub_date': pubDate?.toIso8601String(),
      'pub_updated': pubUpdated?.toIso8601String(),
      'feed_type': feedtype?.name,
      'language': language,
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
      pubDate: map['pub_date'] != null
          ? DateTime.parse(map['pub_date'] as String)
          : null,
      pubUpdated: map['pub_updated'] != null
          ? DateTime.parse(map['pub_updated'] as String)
          : null,
      feedtype: map['feed_type'] != null
          ? FeedType.fromString(map['feed_type'] as String)
          : null,
      language: map['language'] != null ? map['language'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory FeedModel.fromJson(String source) =>
      FeedModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FeedModel(id: $id, title: $title, description: $description, link: $link, feedLink: $feedLink, pubDate: $pubDate, pubUpdated: $pubUpdated, feedtype: $feedtype, language: $language)';
  }

  @override
  bool operator ==(covariant FeedModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.description == description &&
        other.link == link &&
        other.feedLink == feedLink &&
        other.pubDate == pubDate &&
        other.pubUpdated == pubUpdated &&
        other.feedtype == feedtype &&
        other.language == language;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        link.hashCode ^
        feedLink.hashCode ^
        pubDate.hashCode ^
        pubUpdated.hashCode ^
        feedtype.hashCode ^
        language.hashCode;
  }
}
