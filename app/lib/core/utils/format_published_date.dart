import 'package:intl/intl.dart';

String formatPublishedDate(DateTime publishedDate) {
  DateTime now = DateTime.now();
  Duration difference = now.difference(publishedDate);

  if (difference.inDays > 365) {
    // More than 12 months ago, return in "dd MMM yy" format
    return DateFormat('dd MMM yy').format(publishedDate);
  } else if (difference.inDays > 7) {
    // More than 7 days but less than 12 months, return in "dd MMM" format
    return DateFormat('dd MMM').format(publishedDate);
  } else if (difference.inDays >= 1) {
    // More than 1 day but less than 7 days, return in "Xd"
    return '${difference.inDays}d';
  } else if (difference.inHours >= 1) {
    // More than 1 hour but less than 1 day, return in "Xh Ym"
    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);
    if (minutes > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${hours}h';
  } else if (difference.inMinutes >= 1) {
    // More than 1 minute but less than 1 hour, return in "Xm"
    return '${difference.inMinutes}m';
  } else {
    // Less than 1 minute, return "now"
    return 'now';
  }
}
