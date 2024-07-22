class TextConstants {
  static const String networkConnectedMessage = 'You are now online!';
  static const String networkDisconnectedMessage = 'You are offline';

  static const String internalServerErrorMessage =
      'Something went wrong. Try again later or report the issue';
  static const String usernameTakenErrorMessage = 'This one\'s already taken!';
  static const String usernameBlankErrorMessage =
      'Username should not be blank';
  static const String usernameMinCharsErrorMessage =
      'Username should be atleast 8 characters long';
  static const String usernameMaxCharsErrorMessage =
      'Username should be less than 16 characters long';
  static const String usernameInvalidCharsErrorMessage =
      'Username can only contain letters, numbers, dots, and underscores';
  static const String usernameInvalidPrefixSuffixErrorMessage =
      'Username should not start or end with a dot or an underscore';
  static const String usernameInvalidContentsErrorMessage =
      'Username should not contain consecutive dots, underscores, or their combination';

  static const String feedListFetchErrorTitle = 'Failed to load feeds';
  static const String feedListFetchErrorMessage =
      'Try again later or report the issue';
  static const String feedListEmptyMessageTitle = 'Nothing to see here';
  static const String feedListEmptyMessageMessage =
      'Come back when there are more feeds or add one yourself!';
}
