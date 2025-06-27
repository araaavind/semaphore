import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/services/analytics_service.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/item.dart';
import 'package:app/features/feed/presentation/bloc/liked_items/liked_items_bloc.dart';
import 'package:app/features/feed/presentation/bloc/saved_items/saved_items_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

class ItemListTileActionStrip extends StatelessWidget {
  final Item item;
  final Function(Item)? onItemUpdated;
  final double? paddingTop;

  const ItemListTileActionStrip({
    required this.item,
    this.onItemUpdated,
    this.paddingTop,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: paddingTop ?? 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _buildSubtitle(context)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 10.0),
              _buildActionButton(
                context,
                item.isLiked ? Icons.favorite : Icons.favorite_border,
                iconSize: 20,
                extraPaddingBottom: 0,
                iconColor: item.isLiked ? Colors.red : null,
                () {
                  context.read<LikedItemsBloc>().add(
                        item.isLiked
                            ? UnlikeItemRequested(
                                itemId: item.id,
                                refresh: true,
                              )
                            : LikeItemRequested(item.id),
                      );

                  // Track item liked event
                  if (!item.isLiked) {
                    AnalyticsService.logItemLiked('${item.id}');
                  }

                  onItemUpdated?.call(
                    item.copyWith(
                      isLiked: !item.isLiked,
                    ),
                  );
                },
              ),
              _buildActionButton(
                context,
                item.isSaved ? MingCute.bookmark_fill : MingCute.bookmark_line,
                iconSize: 19,
                extraPaddingBottom: 1,
                iconColor: item.isSaved ? AppPalette.savedAmber : null,
                () {
                  context.read<SavedItemsBloc>().add(
                        item.isSaved
                            ? UnsaveItemRequested(
                                itemId: item.id, refresh: true)
                            : SaveItemRequested(item.id),
                      );

                  // Track item saved event
                  if (!item.isSaved) {
                    AnalyticsService.logItemSaved('${item.id}');
                  }

                  onItemUpdated?.call(
                    item.copyWith(
                      isSaved: !item.isSaved,
                    ),
                  );
                },
              ),
              _buildActionButton(
                context,
                MingCute.share_2_line,
                iconSize: 19,
                extraPaddingBottom: 1,
                () async {
                  // Track article shared event
                  AnalyticsService.logItemShared('${item.id}');

                  try {
                    final result = await SharePlus.instance.share(
                      ShareParams(
                        text:
                            'Hey, check this out!\n\n${item.link}\n\n_shared via *Semaphore* app_',
                      ),
                    );

                    if (result.status != ShareResultStatus.success &&
                        result.status != ShareResultStatus.dismissed &&
                        context.mounted) {
                      showSnackbar(
                        context,
                        'Failed to share article',
                        type: SnackbarType.failure,
                        bottomOffset: kBottomNavigationBarHeight,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      showSnackbar(
                        context,
                        'Failed to share article',
                        type: SnackbarType.failure,
                        bottomOffset: kBottomNavigationBarHeight,
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Row _buildSubtitle(BuildContext context) {
    String? title;
    if (item.feed != null) {
      final feed = item.feed!;
      if (feed.displayTitle != null && feed.displayTitle!.isNotEmpty) {
        title = feed.displayTitle!;
      } else if (feed.title.isNotEmpty) {
        title = feed.title;
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (title != null)
          Flexible(
            child: AutoSizeText(
              title,
              style: context.theme.textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                  color: context.theme.colorScheme.onSurface.withAlpha(200)),
              minFontSize: 12,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ),
        if (title != null)
          Text(
            '  •  ',
            style: context.theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w300,
                fontSize: 12,
                color: context.theme.colorScheme.onSurface.withAlpha(200)),
          ),
        Text(
          formatPublishedDateAlt(
            item.pubUpdated ?? item.pubDate ?? item.createdAt,
          ),
          style: context.theme.textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w300,
              fontSize: 12,
              color: context.theme.colorScheme.onSurface.withAlpha(200)),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed, {
    Color? iconColor,
    double? iconSize,
    bool animateOnTap = true,
    double? extraPaddingBottom,
  }) {
    return AnimatedIconButton(
      icon: Icon(
        icon,
        size: iconSize ?? 20,
        color: iconColor?.withAlpha(200) ??
            context.theme.colorScheme.onSurface.withAlpha(200),
      ),
      padding: EdgeInsets.only(
        bottom: extraPaddingBottom ?? 0,
        left: 8,
        right: 8,
      ),
      onPressed: onPressed,
      animateOnTap: animateOnTap,
    );
  }
}
