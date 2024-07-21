class ServerConstants {
  static const String baseUrl = 'http://192.168.1.4:5000/v1';
  static String persistSessionKey =
      'sm-${Uri.parse(baseUrl).host.split(".").first}-session';

  static const int defaultPaginationPageSize = 12;
  static const int defaultPaginationNextPageSize = 8;

  static const throttleDuration = Duration(milliseconds: 100);
}
