import 'package:html/parser.dart' as html_parser;

/// Utility class for HTML-related operations
class HtmlUtils {
  /// Converts HTML content to plain text by removing all HTML tags
  /// and decoding HTML entities.
  ///
  /// This is a lightweight approach with minimal overhead.
  ///
  /// Example:
  /// ```dart
  /// final htmlText = '<p>Hello <strong>world</strong>!</p>';
  /// final plainText = HtmlUtils.htmlToPlainText(htmlText);
  /// // Result: "Hello world!"
  /// ```
  static String htmlToPlainText(String? htmlString) {
    if (htmlString == null || htmlString.isEmpty) {
      return '';
    }

    // If the string doesn't contain HTML tags, return as-is
    if (!htmlString.contains('<') || !htmlString.contains('>')) {
      return htmlString;
    }

    try {
      // Parse the HTML and extract text content
      final document = html_parser.parse(htmlString);
      final text = document.body?.text ?? document.documentElement?.text ?? '';

      // Remove extra whitespace and normalize line breaks
      return text.trim().replaceAll(RegExp(r'\s+'), ' ');
    } catch (e) {
      // If parsing fails, fall back to regex-based tag removal
      return _fallbackStripHtml(htmlString);
    }
  }

  /// Fallback method to strip HTML tags using regex
  /// Used when HTML parsing fails
  static String _fallbackStripHtml(String htmlString) {
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();
  }
}
