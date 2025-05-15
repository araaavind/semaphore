part of 'rss.dart';

// Create a single Dio instance for reuse
final _dio = Dio();

class ConverterException implements Exception {
  final String message;
  ConverterException(this.message);
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
    throw ConverterException('URL cannot be empty');
  }

  // Normalize URL (add https:// if missing)
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = 'https://$url';
  }

  final Uri uri;
  try {
    uri = Uri.parse(url.trim());
  } catch (e) {
    throw ConverterException('Invalid URL format: $e');
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
    throw ConverterException('Subreddit cannot be empty');
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
    throw ConverterException('Substack input cannot be empty');
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

    throw ConverterException('Could not extract username from Substack URL');
  } catch (e) {
    throw ConverterException('Invalid Substack URL format: $e');
  }
}

/// Converts a YouTube URL or username to its RSS feed URL
///
/// This utility function handles YouTube inputs in the formats:
/// - youtube.com/@USERNAME (handle)
/// - youtube.com/channel/CHANNEL_ID (direct channel ID)
/// - youtube.com/playlist?list=PLAYLIST_ID (playlist)
/// - youtube.com/watch?v=VIDEO_ID&list=PLAYLIST_ID (video in a playlist)
/// - @USERNAME (handle)
///
/// Returns the RSS feed URL for the YouTube content
Future<String> _convertYoutubeToRssUrl(String input) async {
  if (input.isEmpty) {
    throw ConverterException('YouTube input cannot be empty');
  }

  final cleanInput = input.trim();

  // Handle direct @username format - need to resolve channel ID via API
  if (cleanInput.startsWith('@') && !cleanInput.contains('/')) {
    final handle = cleanInput;
    return await _resolveYoutubeHandleToRssUrl(handle);
  }

  // Handle URL formats
  var urlToCheck = cleanInput;
  if (!urlToCheck.startsWith('http://') && !urlToCheck.startsWith('https://')) {
    urlToCheck = 'https://$urlToCheck';
  }

  try {
    final uri = Uri.parse(urlToCheck);

    // Make sure it's a YouTube domain
    if (uri.host != 'youtube.com' &&
        uri.host != 'www.youtube.com' &&
        uri.host != 'youtu.be') {
      throw ConverterException('Not a valid YouTube URL');
    }

    // Channel format: youtube.com/channel/CHANNEL_ID (direct channel ID)
    if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'channel') {
      final channelId = uri.pathSegments[1];
      return 'https://www.youtube.com/feeds/videos.xml?channel_id=$channelId';
    }

    // Playlist format: youtube.com/playlist?list=PLAYLIST_ID
    // Or video within playlist: youtube.com/watch?v=VIDEO_ID&list=PLAYLIST_ID
    if ((uri.pathSegments.contains('playlist') ||
            uri.pathSegments.contains('watch')) &&
        uri.queryParameters.containsKey('list')) {
      final playlistId = uri.queryParameters['list']!;
      return 'https://www.youtube.com/feeds/videos.xml?playlist_id=$playlistId';
    }

    // Handle format: youtube.com/@USERNAME (handle)
    if (uri.pathSegments.isNotEmpty && uri.pathSegments[0].startsWith('@')) {
      final handle = uri.pathSegments[0];
      return await _resolveYoutubeHandleToRssUrl(handle);
    }

    // If none of the above match and there's a standard URL, try to resolve with the API
    throw ConverterException('Unable to determine YouTube feed type from URL');
  } catch (e) {
    throw ConverterException('Invalid YouTube URL format');
  }
}

/// Resolves a YouTube handle to a channel ID using the server API
/// and returns the RSS feed URL
Future<String> _resolveYoutubeHandleToRssUrl(String handle) async {
  if (!handle.startsWith('@')) {
    throw ConverterException(
        'Invalid YouTube handle format, must start with @');
  }

  try {
    // Build API URL to resolve handle to channel ID
    final apiUrl =
        '${ServerConstants.baseUrl}${ServerConstants.youtubeChannelEndpoint}?handle=${Uri.encodeComponent(handle)}';

    // Make request to our server API using the shared Dio instance
    final response = await _dio.get(apiUrl);

    // Check response status
    if (response.statusCode == 200) {
      // Parse the JSON response (Dio automatically parses JSON)
      final data = response.data;

      // Extract the channel ID
      final String channelId = data['channel_id'];

      if (channelId.isEmpty) {
        throw ConverterException(
            'Failed to add this feed. Check the input and try again');
      }

      // Return RSS feed URL with the channel ID
      return 'https://www.youtube.com/feeds/videos.xml?channel_id=$channelId';
    } else {
      throw ConverterException(
          'Failed to add this feed. Check the input and try again');
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    throw ConverterException(
        'Failed to add this feed. Check the input and try again');
  }
}
