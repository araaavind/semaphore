import 'package:app/core/constants/constants.dart';
import 'package:app/features/feed/domain/entities/item.dart';
import 'package:app/init_dependencies.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>> getItemImageUrls(
  Item item, {
  bool includeFavicon = true,
  bool scrapeFromLink = true,
}) async {
  final imageUrls = <String>[];
  if (item.imageUrl != null) imageUrls.add(item.imageUrl!);
  if (item.enclosures != null) {
    for (var e in item.enclosures!) {
      if (e.type != null && e.type == '/image' && e.url != null) {
        imageUrls.add(e.url!);
      }
    }
    for (var e in item.enclosures!) {
      if (e.url != null) {
        final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
        final uri = Uri.tryParse(e.url!);
        if (uri != null &&
            uri.hasAbsolutePath &&
            imageExtensions
                .any((ext) => e.url!.toLowerCase().contains('.$ext'))) {
          imageUrls.add(e.url!);
        }
      }
    }
  }

  final imageUrlsFromDescription =
      _extractBestImageUrlsFromContent(item.description);
  final imageUrlsFromContent = _extractBestImageUrlsFromContent(item.content);
  imageUrls.addAll([
    ...imageUrlsFromDescription,
    ...imageUrlsFromContent,
  ]);

  if (imageUrls.isNotEmpty) {
    return imageUrls;
  } else if (scrapeFromLink) {
    imageUrls.addAll(await _scrapeCachedImageUrlsFromLink(
      item.link,
      includeFavicon: includeFavicon,
    ));
  }

  return imageUrls.isNotEmpty ? imageUrls : [''];
}

/// Extracts the largest image URL if width and height attributes are available.
/// If not, checks for images inside specific tags like "featured".
/// If none are found, returns any image element as a fallback.
List<String> _extractBestImageUrlsFromContent(String? content) {
  if (content == null) return [];

  final imageUrls = <String>[];

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
    imageUrls.add(largestImageElement.attributes['src']!);
  }

  // 2. try to find images inside specific tags like "featured"
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
        imageUrls.add(src);
        imgElements.removeWhere((element) => element == imgElement);
      }
    }
  }

  // 3. Push remaining image elements
  for (Element imgElement in imgElements) {
    String? src = imgElement.attributes['src'];
    if (src != null && src.isNotEmpty) {
      imageUrls.add(src);
    }
  }

  return imageUrls;
}

Future<List<String>> _scrapeCachedImageUrlsFromLink(String? link,
    {bool includeFavicon = true}) async {
  if (link == null || link.isEmpty) return [];

  final prefs = serviceLocator<SharedPreferencesWithCache>();
  final cacheKey = 'image_url_cache_${base64Encode(utf8.encode(link))}';
  const cacheKeysListKey = 'image_url_cache_keys';

  // Check if cached URLs exists and is still valid
  final cachedData = prefs.getString(cacheKey);
  if (cachedData != null) {
    final cachedMap = json.decode(cachedData);
    final expirationTime = DateTime.parse(cachedMap['expiration']);
    if (DateTime.now().isBefore(expirationTime)) {
      // Move to the end of the keys list
      final keysList = prefs.getStringList(cacheKeysListKey) ?? [];
      keysList.remove(cacheKey);
      keysList.add(cacheKey);
      await prefs.setStringList(cacheKeysListKey, keysList);
      return List<String>.from(cachedMap['urls']);
    } else {
      await prefs.remove(cacheKey);
      final keysList = prefs.getStringList(cacheKeysListKey) ?? [];
      keysList.remove(cacheKey);
      await prefs.setStringList(cacheKeysListKey, keysList);
    }
  }

  // If no valid cache exists, scrape the URL
  final scrapedUrls =
      await _scrapeImageUrlsFromLink(link, includeFavicon: includeFavicon);

  final cacheData = json.encode({
    // Store only the first 3 image URLs to save space
    'urls': scrapedUrls.length > 2 ? scrapedUrls.sublist(0, 3) : scrapedUrls,
    'expiration': DateTime.now()
        .add(
          const Duration(
            minutes: ServerConstants.maxImageUrlCacheDurationInMinutes,
          ),
        )
        .toIso8601String(),
  });
  await prefs.setString(cacheKey, cacheData);
  final keysList = prefs.getStringList(cacheKeysListKey) ?? [];
  keysList.add(cacheKey);
  await prefs.setStringList(cacheKeysListKey, keysList);
  if (keysList.length > ServerConstants.maxImageUrlCacheSize) {
    final keysToRemove = keysList.sublist(
      0,
      keysList.length - ServerConstants.maxImageUrlCacheSize,
    );
    for (var key in keysToRemove) {
      await prefs.remove(key);
    }
    await prefs.setStringList(
      cacheKeysListKey,
      keysList.sublist(
        keysList.length - ServerConstants.maxImageUrlCacheSize,
      ),
    );
  }

  return scrapedUrls;
}

Future<List<String>> _scrapeImageUrlsFromLink(String link,
    {bool includeFavicon = true}) async {
  final dio = Dio();
  try {
    final response = await dio.get(Uri.parse(link).toString());
    if (response.statusCode != 200) return [];

    final links = <String>[];

    final document = html_parser.parse(response.data);

    // Check Open Graph and Twitter Card meta tags
    final metaTags = document.getElementsByTagName('meta');
    for (var tag in metaTags) {
      final property = tag.attributes['property'] ?? tag.attributes['name'];
      if (property == 'og:image' || property == 'twitter:image') {
        if (tag.attributes['content'] != null) {
          links.add(tag.attributes['content']!);
        }
      }
    }

    // Check JSON-LD
    final scriptTags = document.getElementsByTagName('script');
    for (var tag in scriptTags) {
      if (tag.attributes['type'] == 'application/ld+json') {
        final jsonLd = json.decode(tag.text);
        if (jsonLd is Map && jsonLd.containsKey('image')) {
          if (jsonLd['image'] is Map && jsonLd['image'].containsKey('url')) {
            if (jsonLd['image']['url'] != null &&
                jsonLd['image']['url'].isNotEmpty) {
              links.add(jsonLd['image']['url']);
            }
          } else if (jsonLd['image'] is List) {
            for (var image in jsonLd['image']) {
              if (image is Map && image.containsKey('url')) {
                if (image['url'] != null && image['url'].isNotEmpty) {
                  links.add(image['url']);
                }
              } else if (image is String) {
                if (image.isNotEmpty) {
                  links.add(image);
                }
              }
            }
          } else if (jsonLd['image'] is String) {
            links.add(jsonLd['image']);
          }
        }
      }
    }

    // Fallback to the first image in the HTML
    final imgTags = document.getElementsByTagName('img');
    if (imgTags.isNotEmpty) {
      for (var tag in imgTags) {
        if (tag.attributes['src'] != null) {
          final src = tag.attributes['src']!;
          if (Uri.parse(src).isAbsolute) {
            links.add(src);
          } else {
            // Handle relative URLs
            final baseUri = Uri.parse(link);
            final absoluteUri = baseUri.resolve(src);
            links.add(absoluteUri.toString());
          }
        }
      }
    }

    if (includeFavicon) {
      // Check for favicons
      final linkTags = document.getElementsByTagName('link');
      for (var tag in linkTags) {
        final rel = tag.attributes['rel'];
        if (rel == 'icon' ||
            rel == 'shortcut icon' ||
            rel == 'apple-touch-icon' ||
            rel == 'apple-touch-icon-precomposed' ||
            rel == 'icon shortcut') {
          if (tag.attributes['href'] != null) {
            final href = tag.attributes['href']!;
            if (Uri.parse(href).isAbsolute) {
              links.add(href);
            } else {
              // Handle relative URLs
              final baseUri = Uri.parse(link);
              final absoluteUri = baseUri.resolve(href);
              links.add(absoluteUri.toString());
            }
          }
        }
      }
    }

    return links;
  } catch (e) {
    if (kDebugMode) {
      print('Error scraping image from link $link\nError: $e');
    }

    return [];
  }
}
