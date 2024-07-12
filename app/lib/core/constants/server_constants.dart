class ServerConstants {
  static const String baseUrl = 'http://192.168.1.5:5000/v1';
  static String persistSessionKey =
      'sm-${Uri.parse(baseUrl).host.split(".").first}-session';

  static const int defaultPaginationPage = 1;
  static const int defaultPaginationPageSize = 8;

  static const String internalServerErrorMessage =
      'Something went wrong. Try again later or report the issue';
}

enum LogoutScope {
  /// All sessions by this account will be signed out.
  global,

  /// Only this session will be signed out.
  local,

  /// All other sessions except the current one will be signed out. When using others, there is no [AuthChangeEvent.signedOut] event fired on the current session!
  others,
}
