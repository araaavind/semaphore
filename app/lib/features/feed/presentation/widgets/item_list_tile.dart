import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/format_published_date.dart';
import 'package:app/core/utils/string_casing_extension.dart';
import 'package:app/features/feed/domain/entities/item.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ItemListTile extends StatelessWidget {
  final Item item;
  const ItemListTile({
    required this.item,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
      leading: item.imageUrl != null
          ? Container(
              height: 50,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    item.imageUrl!,
                  ),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            )
          : null,
      visualDensity: VisualDensity.comfortable,
      splashColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: UIConstants.pagePadding,
      ),
      title: AutoSizeText(
        item.title.toTitleCase(),
        style: context.theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        minFontSize: context.theme.textTheme.bodyLarge!.fontSize!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (item.feed?.title != null && item.feed!.title.isNotEmpty)
            Container(
              constraints: BoxConstraints.loose(
                Size.fromWidth(
                  MediaQuery.of(context).size.width - 120,
                ),
              ),
              child: AutoSizeText(
                item.feed!.title,
                style: context.theme.textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w300,
                    color:
                        context.theme.colorScheme.onSurface.withOpacity(0.7)),
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
          if ((item.feed?.title != null && item.feed!.title.isNotEmpty) &&
              (item.pubDate != null || item.pubUpdated != null))
            Text(
              '   •   ',
              style: context.theme.textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w300,
                  color: context.theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
          if (item.pubDate != null || item.pubUpdated != null)
            Text(
              formatPublishedDate(
                item.pubUpdated ?? item.pubDate ?? DateTime.now(),
              ),
              style: context.theme.textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w300,
                  color: context.theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
        ],
      ),
      horizontalTitleGap: UIConstants.tileHorizontalTitleGap,
    );
  }
}
