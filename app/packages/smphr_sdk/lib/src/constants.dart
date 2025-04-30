class Constants {
  // HTTP Constants
  static const String defaultBaseUrl = 'http://127.0.0.1:5000/';
  static const Duration defaultConnectTimeout = Duration(seconds: 8);
  static const Duration defaultReceiveTimeout = Duration(seconds: 5);

  static const int httpInternalServerErrorCode = 500;

  // Error messages
  static const String internalServerErrorMessage =
      'An unexpected error occured. Please try again later';
  static const String sessionExpiredErrorMessage =
      'Session Expired! Please login again';
  static const String connectionTimeoutErrorMessage =
      'Could not connect to the server. Check your internet or try again later';
  static const String receiveTimeoutErrorMessage =
      'Took too long to get response. Please try again later';
  static const String connectionErrorMessage =
      'Cannot connect to server. Check your internet or try again later';
  static const String tokenRefreshErrorMessage =
      'Could not refresh session. Please login again';
  static const String authenticationRequiredErrorMessage =
      'You are not logged in';
  static const String activationRequiredErrorMessage =
      'You must activate your account to perform this action';
  static const String invalidInputErrorMessage =
      'Something went wrong. Check your inputs';
  static const String unprocessableEntityErrorMessage =
      'Something went wrong. Request cannot be processed';
  static const String notFoundErrorMessage =
      'Could not find what you\'re looking for';

  //
  static const defaultPersistSessionKey = 'sm-session';

  // The margin to use when checking if a token is expired.
  static const expiryMargin = Duration(seconds: 10);
}

enum SignOutScope {
  /// All sessions by this account will be signed out.
  global,

  /// Only this session will be signed out.
  local,

  /// All other sessions except the current one will be signed out. When using others, there is no [AuthChangeEvent.signedOut] event fired on the current session!
  others;

  static SignOutScope fromString(String s) => switch (s) {
        'global' => global,
        'local' => local,
        'others' => others,
        _ => local
      };
}
