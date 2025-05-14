import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:flutter/material.dart';

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

String? _subredditValidator(value) {
  if (value!.isEmpty) {
    return 'Please enter a subreddit name';
  }

  // Basic validation for subreddit name
  const subredditPattern = r'^(r\/)?[a-zA-Z0-9_]{3,21}$';
  final RegExp validCharsRegex = RegExp(subredditPattern);

  if (!validCharsRegex.hasMatch(value)) {
    return 'Please enter a valid subreddit name (e.g., r/flutter)';
  }

  return null;
}

String? _feedUrlValidator(String? value) {
  const urlPattern = r'^(https?:\/\/)?' // Optional protocol
      r'((([a-zA-Z0-9\-]+\.)+[a-zA-Z]{2,})' // Domain name and extension
      r'|'
      r'((\d{1,3}\.){3}\d{1,3}))' // OR IPv4
      r'(:\d+)?' // Optional port
      r'(\/[-a-zA-Z0-9%_.~+]*)*' // Path
      r'(\?[;&a-zA-Z0-9%_.~+=-]*)?' // Query string
      r'(#[-a-zA-Z0-9_]*)?$'; // Fragment locator
  final RegExp validCharsRegex = RegExp(urlPattern);
  if (value!.isEmpty) {
    return TextConstants.feedUrlBlankErrorMessage;
  } else if (!validCharsRegex.hasMatch(value)) {
    return TextConstants.feedUrlNotUrlErrorMessage;
  }
  return null;
}

String? _mediumUrlValidator(String? value) {
  const urlPattern = r'^(https?:\/\/)?' // Optional protocol
      r'((([a-zA-Z0-9\-]+\.)+[a-zA-Z]{2,})' // Domain name and extension
      r'|'
      r'((\d{1,3}\.){3}\d{1,3}))' // OR IPv4
      r'(:\d+)?' // Optional port
      r'(\/[-a-zA-Z0-9%_.~+@]*)*' // Path
      r'(\?[;&a-zA-Z0-9%_.~+=-]*)?' // Query string
      r'(#[-a-zA-Z0-9_]*)?$'; // Fragment locator
  final RegExp validCharsRegex = RegExp(urlPattern);
  if (value!.isEmpty) {
    return TextConstants.feedUrlBlankErrorMessage;
  } else if (!validCharsRegex.hasMatch(value)) {
    return TextConstants.feedUrlNotUrlErrorMessage;
  }
  return null;
}

/// Converts a Medium blog URL to its RSS feed URL
///
/// This utility function handles various Medium URL formats including:
/// - Standard Medium URLs (medium.com/@username)
/// - User subdomain profiles (username.medium.com)
/// - Custom domain Medium publications
/// - Medium subdomain publications (*.medium.com)
/// - Medium stories (medium.com/@username/story-title-hash)
/// - Medium publications with stories (medium.com/publication/story-title-hash)
/// - Tagged pages in a publication (medium.com/publication-name/tagged/tag-name)
/// - Topic pages (medium.com/tag/tag-name)
///
/// If the URL doesn't match known Medium patterns, it will attempt to fetch
/// the original URL and look for an RSS link in the HTML header as fallback.
///
/// Returns the RSS feed URL or throws an exception if no feed can be found.
String _convertMediumUrlToRss(String url) {
  if (url.isEmpty) {
    throw Exception('URL cannot be empty');
  }

  // Normalize URL (add https:// if missing)
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = 'https://$url';
  }

  final Uri uri;
  try {
    uri = Uri.parse(url.trim());
  } catch (e) {
    throw Exception('Invalid URL format: $e');
  }

  // Handle username.medium.com format (user profile)
  if (uri.host.endsWith('.medium.com') && !uri.host.startsWith('www.')) {
    final username = uri.host.split('.').first;
    if (username.isNotEmpty) {
      // For username.medium.com, return username.medium.com/feed
      return 'https://${uri.host}/feed';
    }
  }

  // Handle standard medium.com URLs
  if (uri.host == 'medium.com') {
    // Handle topic pages - medium.com/tag/tag-name
    if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'tag') {
      final tagName = uri.pathSegments[1];
      return 'https://medium.com/feed/tag/$tagName';
    }

    // Handle user profiles - medium.com/@username
    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first.startsWith('@')) {
      final username = uri.pathSegments.first.substring(1);
      // If it's a user's story, still return the user's feed
      // medium.com/@username/story-title-hash
      return 'https://medium.com/feed/@$username';
    }

    // Handle medium.com publications with tagged content - medium.com/publication-name/tagged/tag-name
    if (uri.pathSegments.length >= 3 && uri.pathSegments[1] == 'tagged') {
      final publicationName = uri.pathSegments[0];
      final tagName = uri.pathSegments[2];
      return 'https://medium.com/feed/$publicationName/tagged/$tagName';
    }

    // Handle medium.com publications - medium.com/publication-name
    if (uri.pathSegments.isNotEmpty) {
      final publicationName = uri.pathSegments.first;

      // If there are additional path segments, preserve them
      if (uri.pathSegments.length > 1) {
        final additionalPath = uri.pathSegments.skip(1).join('/');
        return 'https://medium.com/feed/$publicationName/$additionalPath';
      }

      return 'https://medium.com/feed/$publicationName';
    }

    // Handle medium.com root
    return 'https://medium.com/feed/';
  }

  // Handle Medium publication on subdomain (e.g., xyz.medium.com)
  if (uri.host.endsWith('.medium.com')) {
    // If there are path segments, preserve them
    if (uri.pathSegments.isNotEmpty) {
      final path = uri.pathSegments.join('/');
      return 'https://${uri.host}/feed/$path';
    }
    return 'https://${uri.host}/feed';
  }

  // For all other URLs on custom domains, return the host as the feed URL
  return 'https://${uri.host}/feed';
}

/// Converts a subreddit name to its RSS feed URL
///
/// This utility function handles subreddit inputs in the formats:
/// - r/subreddit
/// - subreddit
///
/// Returns the RSS feed URL for the subreddit
String _convertSubredditToRssUrl(String subreddit) {
  if (subreddit.isEmpty) {
    throw Exception('Subreddit cannot be empty');
  }

  // Remove any leading or trailing whitespace
  final cleanSubreddit = subreddit.trim();

  // Handle subreddit with or without 'r/' prefix
  if (!cleanSubreddit.startsWith('r/') && !cleanSubreddit.startsWith('/r/')) {
    return 'https://www.reddit.com/r/${cleanSubreddit}.rss';
  } else {
    return 'https://www.reddit.com/${cleanSubreddit}.rss';
  }
}

/// Validates a Substack username or URL
///
/// This function validates Substack inputs in the formats:
/// - @username
/// - https://substack.com/@username
/// - https://username.substack.com
/// - substack.com/@username
/// - username.substack.com
String? _substackValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a Substack username or URL';
  }

  final cleanValue = value.trim();

  // Handle @username format
  if (cleanValue.startsWith('@')) {
    final username = cleanValue.substring(1);
    if (username.isEmpty) {
      return 'Please enter a valid Substack username';
    }

    // Basic validation for username
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(username)) {
      return 'Username should only contain letters, numbers, underscores, and hyphens';
    }

    return null;
  }

  // Handle URL formats
  var urlToCheck = cleanValue;
  if (!urlToCheck.startsWith('http://') && !urlToCheck.startsWith('https://')) {
    urlToCheck = 'https://$urlToCheck';
  }

  Uri? uri;
  try {
    uri = Uri.parse(urlToCheck);
  } catch (e) {
    return 'Invalid URL format';
  }

  // Check if it's a substack.com domain
  if (uri.host == 'substack.com') {
    // Check if path starts with @username
    if (uri.pathSegments.isEmpty || !uri.pathSegments.first.startsWith('@')) {
      return 'Invalid Substack URL format. Should be substack.com/@username';
    }

    final username = uri.pathSegments.first.substring(1);
    if (username.isEmpty) {
      return 'Please enter a valid Substack username';
    }

    return null;
  }
  // Check if it's a username.substack.com domain
  else if (uri.host.endsWith('.substack.com')) {
    final parts = uri.host.split('.');
    if (parts.length < 2 || parts[0].isEmpty) {
      return 'Invalid Substack URL format. Should be username.substack.com';
    }

    return null;
  }

  return 'Not a valid Substack username or URL';
}

/// Converts a Substack username or URL to its RSS feed URL
///
/// This utility function handles Substack inputs in the formats:
/// - @username
/// - https://substack.com/@username
/// - https://username.substack.com
/// - substack.com/@username
/// - username.substack.com
///
/// Returns the RSS feed URL in the format: https://username.substack.com/feed
String _convertSubstackToRssUrl(String input) {
  if (input.isEmpty) {
    throw Exception('Substack input cannot be empty');
  }

  final cleanInput = input.trim();
  String username;

  // Handle @username format
  if (cleanInput.startsWith('@')) {
    username = cleanInput.substring(1);
    return 'https://$username.substack.com/feed';
  }

  // Handle URL formats
  var urlToCheck = cleanInput;
  if (!urlToCheck.startsWith('http://') && !urlToCheck.startsWith('https://')) {
    urlToCheck = 'https://$urlToCheck';
  }

  try {
    final uri = Uri.parse(urlToCheck);

    // Handle substack.com/@username format
    if (uri.host == 'substack.com') {
      if (uri.pathSegments.isNotEmpty &&
          uri.pathSegments.first.startsWith('@')) {
        username = uri.pathSegments.first.substring(1);
        return 'https://$username.substack.com/feed';
      }
    }
    // Handle username.substack.com format
    else if (uri.host.endsWith('.substack.com')) {
      final parts = uri.host.split('.');
      if (parts.length >= 2) {
        username = parts[0];
        return 'https://$username.substack.com/feed';
      }
    }

    throw Exception('Could not extract username from Substack URL');
  } catch (e) {
    throw Exception('Invalid Substack URL format: $e');
  }
}
