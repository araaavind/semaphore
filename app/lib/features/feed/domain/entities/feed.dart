class Feed {
  final int id;
  final String title;
  final String? description;
  final String link;
  final String feedLink;
  final DateTime? pubDate;
  final DateTime? pubUpdated;
  final FeedType? feedtype;
  final String? language;

  Feed({
    required this.id,
    required this.title,
    this.description,
    required this.link,
    required this.feedLink,
    this.pubDate,
    this.pubUpdated,
    this.feedtype,
    this.language,
  });
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
