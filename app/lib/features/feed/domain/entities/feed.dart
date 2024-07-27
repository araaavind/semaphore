import 'package:equatable/equatable.dart';

class Feed extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String link;
  final String feedLink;
  final DateTime? pubDate;
  final DateTime? pubUpdated;
  final FeedType? feedType;
  final String? language;

  const Feed({
    required this.id,
    required this.title,
    this.description,
    required this.link,
    required this.feedLink,
    this.pubDate,
    this.pubUpdated,
    this.feedType,
    this.language,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        link,
        feedLink,
        pubDate,
        pubUpdated,
        feedType,
        language,
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
