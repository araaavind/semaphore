part of 'rss.dart';

/// Validates a Subreddit name
///
/// This function validates subreddit names in the format:
/// - r/subreddit
/// - subreddit
///
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

/// Validates a feed URL
///
/// This function validates feed URLs in the format:
/// - https://example.com/feed
/// - http://example.com/feed
/// - example.com/feed
///
String? _feedUrlValidator(String? value) {
  if (value == null || value.isEmpty) {
    return TextConstants.feedUrlBlankErrorMessage;
  }

  try {
    // Use Uri.parse to validate instead of regex
    final uri = Uri.parse(value.startsWith('http') ? value : 'https://$value');

    // Basic validation that we have at least a host
    if (uri.host.isEmpty) {
      return TextConstants.feedUrlNotUrlErrorMessage;
    }

    return null;
  } catch (e) {
    return TextConstants.feedUrlNotUrlErrorMessage;
  }
}

/// Validates a Medium URL
///
/// This function validates Medium URLs in the format:
/// - https://medium.com/@username
/// - https://medium.com/username
/// - https://medium.com/username/post-id
///
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

/// Validates a YouTube channel, user, or playlist URL/identifier
///
/// This function validates YouTube inputs in the formats:
/// - youtube.com/@USERNAME (handle)
/// - youtube.com/channel/CHANNEL_ID
/// - youtube.com/playlist?list=PLAYLIST_ID
/// - youtube.com/watch?v=VIDEO_ID&list=PLAYLIST_ID
/// - @USERNAME (handle)
///
String? _youtubeValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a YouTube channel handle (eg., @ChannelName), or URL';
  }

  final cleanValue = value.trim();

  // Handle direct @username format
  if (cleanValue.startsWith('@') && !cleanValue.contains('/')) {
    final username = cleanValue.substring(1);
    if (username.isEmpty) {
      return 'Please enter a valid YouTube channel handle';
    }

    // Basic validation for username
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(username)) {
      return 'Channel handle should only contain letters, numbers, underscores, and hyphens';
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

  // Check if it's a youtube.com domain or youtu.be (shortened URLs)
  if (uri.host != 'youtube.com' &&
      uri.host != 'www.youtube.com' &&
      uri.host != 'm.youtube.com' &&
      uri.host != 'youtu.be') {
    return 'Not a valid YouTube URL or channel handle';
  }

  // Validate specific YouTube URL formats
  if (uri.pathSegments.isEmpty) {
    return 'Invalid YouTube URL format';
  }

  // Channel format: youtube.com/channel/CHANNEL_ID
  if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'channel') {
    final channelId = uri.pathSegments[1];
    if (channelId.isEmpty) {
      return 'Missing channel ID in URL';
    }
    // Basic validation for channel ID (usually starts with 'UC')
    if (!RegExp(r'^[a-zA-Z0-9_-]{24}$').hasMatch(channelId)) {
      return 'Invalid YouTube channel ID format';
    }
    return null;
  }

  // Handle format: youtube.com/@USERNAME (handle)
  if (uri.pathSegments.isNotEmpty && uri.pathSegments[0].startsWith('@')) {
    final username = uri.pathSegments[0].substring(1);
    if (username.isEmpty) {
      return 'Missing channel handle(eg., @ChannelName) in URL';
    }
    return null;
  }

  // Playlist format: youtube.com/playlist?list=PLAYLIST_ID
  if (uri.pathSegments.isNotEmpty &&
      uri.pathSegments[0] == 'playlist' &&
      uri.queryParameters.containsKey('list')) {
    final playlistId = uri.queryParameters['list'];
    if (playlistId == null || playlistId.isEmpty) {
      return 'Missing playlist ID in URL';
    }
    return null;
  }

  // Video with playlist: youtube.com/watch?v=VIDEO_ID&list=PLAYLIST_ID
  if (uri.pathSegments.isNotEmpty &&
      uri.pathSegments[0] == 'watch' &&
      uri.queryParameters.containsKey('list')) {
    final playlistId = uri.queryParameters['list'];
    if (playlistId == null || playlistId.isEmpty) {
      return 'Missing playlist ID in URL';
    }
    return null;
  }

  return 'Not a valid YouTube handle, channel, or playlist URL';
}
