import 'package:app/core/common/widgets/item_cached_image.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/saved_item.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SavedItemListTileMag extends StatelessWidget {
  final SavedItem savedItem;
  final bool isTextOnly;
  const SavedItemListTileMag({
    required this.savedItem,
    this.isTextOnly = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          RouteConstants.webViewPageName,
          queryParameters: {
            'url': savedItem.item.link,
            'itemId': savedItem.item.id.toString(),
            'isSaved': savedItem.item.isSaved.toString(),
          },
        );
      },
      splashColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!isTextOnly)
              ItemCachedImage(item: savedItem.item, height: 60, width: 90),
            if (!isTextOnly)
              const SizedBox(width: UIConstants.tileHorizontalTitleGap),
            Expanded(
              child: SizedBox(
                height: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoSizeText(
                      savedItem.item.title[0].toUpperCase() +
                          savedItem.item.title.substring(1),
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      minFontSize: 15,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    _buildSubtitle(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row _buildSubtitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (savedItem.item.feed?.title != null &&
            savedItem.item.feed!.title.isNotEmpty)
          Flexible(
            child: AutoSizeText(
              savedItem.item.feed!.title,
              style: context.theme.textTheme.bodySmall!.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w300,
                color: context.theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.3,
              ),
              minFontSize: 11,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ),
        if ((savedItem.item.feed?.title != null &&
            savedItem.item.feed!.title.isNotEmpty))
          Text(
            '  •  ',
            style: context.theme.textTheme.bodySmall!.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: context.theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.3,
            ),
          ),
        Text(
          formatPublishedDate(
            savedItem.item.pubUpdated ??
                savedItem.item.pubDate ??
                savedItem.item.createdAt,
          ),
          style: context.theme.textTheme.bodySmall!.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: context.theme.colorScheme.onSurface.withOpacity(0.7),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
