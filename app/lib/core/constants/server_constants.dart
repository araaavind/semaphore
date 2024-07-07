class ServerConstants {
  static const String baseUrl = 'http://192.168.1.2:5000/v1';
  static String persistSessionKey =
      'sm-${Uri.parse(baseUrl).host.split(".").first}-session';
}
