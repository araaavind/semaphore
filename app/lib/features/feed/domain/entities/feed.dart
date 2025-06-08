import 'package:equatable/equatable.dart';

class Feed extends Equatable {
  final int id;
  final String? displayTitle;
  final String title;
  final String? description;
  final String link;
  final String feedLink;
  final String? imageUrl;
  final DateTime? pubDate;
  final DateTime? pubUpdated;
  final FeedFormat? feedFormat;
  final FeedType? feedType;
  final OwnerType? ownerType;
  final String? language;
  final int? followersCount;

  const Feed({
    required this.id,
    this.displayTitle,
    required this.title,
    this.description,
    required this.link,
    required this.feedLink,
    this.imageUrl,
    this.pubDate,
    this.pubUpdated,
    this.feedFormat,
    this.feedType,
    this.ownerType,
    this.language,
    this.followersCount,
  });

  @override
  List<Object?> get props => [
        id,
        displayTitle,
        title,
        description,
        link,
        feedLink,
        imageUrl,
        pubDate,
        pubUpdated,
        feedFormat,
        feedType,
        ownerType,
        language,
        followersCount,
      ];
}

enum FeedFormat {
  rss,
  atom,
  json,
  iota;

  static FeedFormat fromString(String s) => switch (s) {
        'rss' => rss,
        'atom' => atom,
        'json' => json,
        _ => iota,
      };
}

enum FeedType {
  website,
  medium,
  reddit,
  youtube,
  substack,
  podcast;

  static FeedType fromString(String s) => switch (s) {
        'website' => website,
        'medium' => medium,
        'reddit' => reddit,
        'youtube' => youtube,
        'substack' => substack,
        'podcast' => podcast,
        _ => website,
      };
}

enum OwnerType {
  personal,
  organization;

  static OwnerType fromString(String s) => switch (s) {
        'personal' => personal,
        'organization' => organization,
        _ => organization,
      };
}
