part of 'rss.dart';

enum FeedInputType {
  url,
  subreddit,
  medium,
  substack,
}

extension FeedTypeExtension on FeedInputType {
  String get displayName {
    switch (this) {
      case FeedInputType.url:
        return 'URL';
      case FeedInputType.subreddit:
        return 'Reddit';
      case FeedInputType.medium:
        return 'Medium';
      case FeedInputType.substack:
        return 'Substack';
    }
  }

  String get hintText {
    switch (this) {
      case FeedInputType.url:
        return 'Feed url';
      case FeedInputType.subreddit:
        return 'r/subreddit';
      case FeedInputType.medium:
        return 'Medium profile/publication url';
      case FeedInputType.substack:
        return '@username or substack.com/@username';
    }
  }

  Color selectedColor(BuildContext context) {
    switch (this) {
      case FeedInputType.url:
        return AppPalette.rssBlue;
      case FeedInputType.subreddit:
        return AppPalette.redditOrange;
      case FeedInputType.medium:
        return context.theme.colorScheme.onSurface;
      case FeedInputType.substack:
        return AppPalette.substackOrange;
    }
  }

  Color labelColor(BuildContext context) {
    switch (this) {
      case FeedInputType.url:
        return context.theme.colorScheme.onSurface;
      case FeedInputType.subreddit:
        return context.theme.colorScheme.onSurface;
      case FeedInputType.medium:
        return context.theme.colorScheme.onSurface;
      case FeedInputType.substack:
        return context.theme.colorScheme.onSurface;
    }
  }

  Color selectedLabelColor(BuildContext context) {
    switch (this) {
      case FeedInputType.url:
        return context.theme.colorScheme.onSurface;
      case FeedInputType.subreddit:
        return context.theme.colorScheme.onSurface;
      case FeedInputType.medium:
        return context.theme.colorScheme.onSurface;
      case FeedInputType.substack:
        return context.theme.colorScheme.onSurface;
    }
  }

  IconData get icon {
    switch (this) {
      case FeedInputType.url:
        return MingCute.link_line;
      case FeedInputType.subreddit:
        return MingCute.reddit_line;
      case FeedInputType.medium:
        return MingCute.medium_line;
      case FeedInputType.substack:
        return SimpleIcons.substack;
    }
  }

  double get iconSize {
    switch (this) {
      case FeedInputType.substack:
        return 14;
      default:
        return 18;
    }
  }

  double get iconPadding {
    switch (this) {
      case FeedInputType.substack:
        return 6;
      default:
        return 4;
    }
  }

  String? Function(String?) get validator {
    switch (this) {
      case FeedInputType.url:
        return _feedUrlValidator;
      case FeedInputType.subreddit:
        return _subredditValidator;
      case FeedInputType.medium:
        return _mediumUrlValidator;
      case FeedInputType.substack:
        return _substackValidator;
    }
  }

  String Function(String) get converter {
    switch (this) {
      case FeedInputType.url:
        return (url) => url;
      case FeedInputType.subreddit:
        return _convertSubredditToRssUrl;
      case FeedInputType.medium:
        return _convertMediumUrlToRss;
      case FeedInputType.substack:
        return _convertSubstackToRssUrl;
    }
  }
}
