import 'package:equatable/equatable.dart';

class Feed extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String link;
  final String feedLink;
  final String? imageUrl;
  final DateTime? pubDate;
  final DateTime? pubUpdated;
  final FeedType? feedType;
  final String? language;
  final int? followersCount;

  const Feed({
    required this.id,
    required this.title,
    this.description,
    required this.link,
    required this.feedLink,
    this.imageUrl,
    this.pubDate,
    this.pubUpdated,
    this.feedType,
    this.language,
    this.followersCount,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        link,
        feedLink,
        imageUrl,
        pubDate,
        pubUpdated,
        feedType,
        language,
        followersCount,
      ];
}

enum FeedType {
  rss,
  atom,
  json,
  unknown;

  static FeedType fromString(String s) => switch (s) {
        'rss' => rss,
        'atom' => atom,
        'json' => json,
        _ => unknown,
      };
}
