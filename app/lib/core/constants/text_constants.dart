class TextConstants {
  static const String networkConnectedMessage = 'You are back online!';
  static const String networkDisconnectedMessage = 'You are offline';

  static const String internalServerErrorMessage =
      'Something went wrong. Try again later or report the issue';

  static const onboardingLoginPageMessage1 = "Your account has been created";
  static const onboardingLoginPageMessage2 = "Log in to continue...";

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

  static const String feedListOnboardingMessage =
      'Follow the feeds that interest you';
  static const String feedListFetchErrorTitle = 'Failed to load feeds';
  static const String feedFollowersFetchErrorTitle = 'Failed to load followers';
  static const String feedFollowersEmptyMessageTitle = 'No followers';
  static const String feedListEmptyMessageTitle = 'That\'s all for now';
  static const String feedListEmptyMessageMessage =
      'Cannot find the feeds that you are looking for?\nAdd them yourself!';

  static const String feedUrlBlankErrorMessage = 'Feed url should not be blank';
  static const String feedUrlNotUrlErrorMessage =
      'Given text is not a valid url';
  static const String feedUrlInvalidErrorMessage =
      'Given url does not point to any valid feed';
  static const String accountActivationSuccessMessage =
      'Your account is now active!';
  static const String passwordResetSuccessMessage =
      'Your password has been reset! Login to continue';

  static const String itemListFetchErrorTitle = 'Failed to load posts';
  static const String itemListNoMoreItemsErrorTitle = 'That\'s all for now';
  static const String itemListNoMoreItemsErrorMessage =
      'Come back later or follow more feeds';
  static const String itemListEmptyMessageTitle = 'Nothing to see here';
  static const String itemListEmptyMessageMessage =
      'Couldn\'t find any posts in this feed';
  static const String itemListEmptyFollowMessageMessage =
      'Follow feeds to see posts';
}
