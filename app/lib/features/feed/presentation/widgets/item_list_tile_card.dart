import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/extract_best_image_url.dart';
import 'package:app/core/utils/format_published_date.dart';
import 'package:app/core/utils/string_casing_extension.dart';
import 'package:app/features/feed/domain/entities/item.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import 'package:shimmer/shimmer.dart';

class ItemListTileCard extends StatelessWidget {
  final Item item;
  const ItemListTileCard({
    required this.item,
    super.key,
  });

  String? getImageUrl(Item item) {
    if (item.imageUrl != null) return item.imageUrl;
    if (item.enclosures != null) {
      for (var e in item.enclosures!) {
        if (e.type != null && e.type == '/image' && e.url != null) {
          return e.url!;
        }
      }
      for (var e in item.enclosures!) {
        if (e.url != null) {
          final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
          final uri = Uri.tryParse(e.url!);

          return uri != null &&
                  uri.hasAbsolutePath &&
                  imageExtensions
                      .any((ext) => e.url!.toLowerCase().contains('.$ext'))
              ? e.url
              : null;
        }
      }
    }
    return extractBestImageUrl(item.description) ??
        extractBestImageUrl(item.content);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final String routeName = GoRouterState.of(context).topRoute!.name!;
        if (routeName == RouteConstants.wallPageName) {
          context.goNamed(
            'webview',
            queryParameters: {'url': item.link},
          );
        } else if (routeName == RouteConstants.feedViewPageName) {
          context.goNamed(
            'feed-webview',
            queryParameters: {'url': item.link},
            pathParameters: GoRouterState.of(context).pathParameters,
            extra: GoRouterState.of(context).extra,
          );
        }
      },
      child: Card(
        margin: EdgeInsets.zero,
        color: context.theme.colorScheme.surface,
        shape: Border.symmetric(
          horizontal: BorderSide(
            color: context.theme.colorScheme.outline,
            width: 0.25,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post header: Subreddit name, posted by username
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (item.feed?.title != null && item.feed!.title.isNotEmpty)
                    Flexible(
                      child: AutoSizeText(
                        item.feed!.title,
                        style: context.theme.textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.w300,
                            color: context.theme.colorScheme.onSurface
                                .withOpacity(0.7)),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                  if ((item.feed?.title != null &&
                          item.feed!.title.isNotEmpty) &&
                      (item.pubDate != null || item.pubUpdated != null))
                    Text(
                      '   •   ',
                      style: context.theme.textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w300,
                          color: context.theme.colorScheme.onSurface
                              .withOpacity(0.7)),
                    ),
                  if (item.pubDate != null || item.pubUpdated != null)
                    Text(
                      formatPublishedDate(
                        item.pubUpdated ?? item.pubDate ?? DateTime.now(),
                      ),
                      style: context.theme.textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w300,
                          color: context.theme.colorScheme.onSurface
                              .withOpacity(0.7)),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Post title
              AutoSizeText(
                item.title.toTitleCase(),
                style: context.theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                minFontSize: context.theme.textTheme.bodyLarge!.fontSize!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Post content (optional image or text)
              if (getImageUrl(item) != null)
                CachedNetworkImage(
                  imageUrl: getImageUrl(item)!,
                  imageBuilder: (context, imageProvider) => Container(
                    height: 180.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: imageProvider,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: context.theme.colorScheme.primary.withAlpha(30),
                    highlightColor:
                        context.theme.colorScheme.primary.withAlpha(65),
                    child: Container(
                      height: 180.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else
                item.description != null && isHtml(item.description!)
                    ? extractTextFromHtml(item.description!).isNotEmpty
                        ? Text(
                            extractTextFromHtml(item.description!),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          )
                        : const SizedBox.shrink()
                    : item.description != null && item.description!.isNotEmpty
                        ? Text(
                            item.description!,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          )
                        : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

String extractTextFromHtml(String htmlString) {
  final document = parse(htmlString);
  final text = dom.DocumentFragment.html(document.body?.text ?? '').text;
  if (['comment', 'comments', 'reply', 'replies']
      .contains(text?.toLowerCase())) {
    return '';
  }
  return text ?? '';
}

bool isHtml(String htmlString) {
  final document = parse(htmlString);
  return document.body?.children.isNotEmpty ?? false;
}
