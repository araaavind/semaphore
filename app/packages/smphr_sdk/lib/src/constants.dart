class Constants {
  static const String defaultBaseUrl = 'http://localhost:5000/';
  static const String internalServerErrorMessage = 'Something went wrong.';
  static const int httpInternalServerErrorCode = 500;

  /// The margin to use when checking if a token is expired.
  static const expiryMargin = Duration(seconds: 30);
}
