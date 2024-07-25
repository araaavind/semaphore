import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/string_casing_extension.dart';
import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class FeedListTile extends StatelessWidget {
  final Feed feed;

  const FeedListTile({
    required this.feed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: UIConstants.borderWidth,
            color: context.theme.colorScheme.outline,
          ),
        ),
      ),
      child: ListTile(
        visualDensity: VisualDensity.standard,
        onTap: () {},
        contentPadding: const EdgeInsets.symmetric(
          vertical: UIConstants.tileContentPadding,
          horizontal: UIConstants.pagePadding,
        ),
        title: AutoSizeText(
          feed.title.toTitleCase(),
          style: context.theme.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w600,
          ),
          minFontSize: context.theme.textTheme.bodyLarge!.fontSize!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: feed.description != null && feed.description!.isNotEmpty
            ? AutoSizeText(
                feed.description!,
                style: context.theme.textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w300,
                ),
                minFontSize: context.theme.textTheme.bodySmall!.fontSize!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        horizontalTitleGap: UIConstants.tileHorizontalTitleGap,
        trailing: IconButton(
          icon: Icon(
            Icons.add_circle_outline_rounded,
            size: 28.0,
            weight: 0.4,
            color: context.theme.colorScheme.primary,
          ),
          onPressed: () {},
        ),
      ),
    );
  }
}
