import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/format_published_date.dart';
import 'package:app/core/utils/string_casing_extension.dart';
import 'package:app/features/feed/domain/entities/item.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ItemListTile extends StatelessWidget {
  final Item item;
  const ItemListTile({
    required this.item,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.standard,
      splashColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(
        vertical: UIConstants.tileContentPadding,
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
          Container(
            constraints: BoxConstraints.loose(
              Size.fromWidth(
                MediaQuery.of(context).size.width - 120,
              ),
            ),
            child: AutoSizeText(
              item.feed?.title ?? 'Unknown feed',
              style: context.theme.textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w300,
                  color: context.theme.colorScheme.onSurface.withOpacity(0.7)),
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ),
          if (item.pubDate != null || item.pubUpdated != null)
            Text(
              '   •   ${formatPublishedDate(
                item.pubUpdated ?? item.pubDate ?? DateTime.now(),
              )}',
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
