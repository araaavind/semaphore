import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/string_casing_extension.dart';
import 'package:app/features/wall/domain/entities/item.dart';
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
        splashColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          vertical: UIConstants.tileContentPadding,
          horizontal: UIConstants.pagePadding,
        ),
        title: AutoSizeText(
          item.title.toTitleCase(),
          style: context.theme.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w600,
          ),
          minFontSize: context.theme.textTheme.bodyLarge!.fontSize!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: item.description != null && item.description!.isNotEmpty
            ? AutoSizeText(
                item.description!,
                style: context.theme.textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w300,
                ),
                minFontSize: context.theme.textTheme.bodySmall!.fontSize!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        horizontalTitleGap: UIConstants.tileHorizontalTitleGap,
      ),
    );
  }
}
