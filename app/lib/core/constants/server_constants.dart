class ServerConstants {
  static const String baseUrl = 'http://192.168.29.67:5000/v1';
  // static const String baseUrl = 'https://smphr.aravindunnikrishnan.in/v1';
  static const String youtubeChannelEndpoint = '/youtube/channel';
  static String persistSessionKey =
      'sm-${Uri.parse(baseUrl).host.split(".").first}-session';

  static const int defaultPaginationPageSize = 8;

  static const throttleDuration = Duration(milliseconds: 100);
  static const debounceDuration = Duration(milliseconds: 300);

  static const int maxImageUrlCacheSize = 100;
  static const int maxImageUrlCacheDurationInMinutes = 10;
}
