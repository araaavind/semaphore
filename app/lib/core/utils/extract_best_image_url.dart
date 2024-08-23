import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

/// Extracts the largest image URL if width and height attributes are available.
/// If not, checks for images inside specific tags like "featured".
/// If none are found, returns any image element as a fallback.
String? extractBestImageUrl(String? content) {
  if (content == null) return null;

  Document document = html_parser.parse(content);

  List<Element> imgElements = document.getElementsByTagName('img');

  // 1. Try to find the largest image based on dimensions with non-empty src
  Element? largestImageElement;
  int largestArea = 0;

  for (Element imgElement in imgElements) {
    String? widthStr = imgElement.attributes['width'];
    String? heightStr = imgElement.attributes['height'];
    String? src = imgElement.attributes['src'];

    // Only consider images with a valid, non-empty src attribute
    if (src != null && src.isNotEmpty) {
      // Convert width and height to integers
      int? width = widthStr != null ? int.tryParse(widthStr) : null;
      int? height = heightStr != null ? int.tryParse(heightStr) : null;

      // Calculate the area (width * height) if dimensions are available
      if (width != null && height != null) {
        int area = width * height;
        if (area > largestArea) {
          largestArea = area;
          largestImageElement = imgElement;
        }
      }
    }
  }

  // Return the largest image if found
  if (largestImageElement != null) {
    return largestImageElement.attributes['src'];
  }

  // 2. If no dimensions are found, try to find images inside specific tags like "featured"
  List<Element> featuredElements = document
      .getElementsByTagName('div')
      .where((element) => element.classes.contains('featured'))
      .toList();

  for (Element featuredElement in featuredElements) {
    List<Element> featuredImgElements =
        featuredElement.getElementsByTagName('img');
    for (Element imgElement in featuredImgElements) {
      String? src = imgElement.attributes['src'];
      if (src != null && src.isNotEmpty) {
        return src;
      }
    }
  }

  // 3. If no featured images are found, fallback to any non-empty image
  for (Element imgElement in imgElements) {
    String? src = imgElement.attributes['src'];
    if (src != null && src.isNotEmpty) {
      return src;
    }
  }

  // Return null if no valid image is found
  return null;
}
