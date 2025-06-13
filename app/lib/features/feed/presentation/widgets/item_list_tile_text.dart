import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/services/analytics_service.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/item.dart';
import 'package:app/features/feed/presentation/bloc/liked_items/liked_items_bloc.dart';
import 'package:app/features/feed/presentation/bloc/saved_items/saved_items_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class ItemListTileText extends StatefulWidget {
  final Item item;
  final Function(Item)? onItemUpdated;

  const ItemListTileText({
    required this.item,
    this.onItemUpdated,
    super.key,
  });

  @override
  State<ItemListTileText> createState() => _ItemListTileTextState();
}

class _ItemListTileTextState extends State<ItemListTileText> {
  late Item _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  void _updateItem(Item updatedItem) {
    setState(() {
      _item = updatedItem;
    });
    widget.onItemUpdated?.call(updatedItem);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SavedItemsBloc, SavedItemsState>(
          listener: (context, state) {
            if (state.status == SavedItemsStatus.failure &&
                state.currentItemId == _item.id &&
                (state.action == SavedItemsAction.unsave ||
                    state.action == SavedItemsAction.save)) {
              _updateItem(
                // if the failed action is save, then set isSaved to false
                // by comparing with unsave
                _item.copyWith(
                  isSaved: state.action == SavedItemsAction.unsave,
                ),
              );
              showSnackbar(
                context,
                state.message ??
                    (state.action == SavedItemsAction.unsave
                        ? 'Failed to unsave article'
                        : 'Failed to save article'),
                type: SnackbarType.failure,
                bottomOffset: kBottomNavigationBarHeight,
              );
            }

            // when user clicks on save button from list tile, the state
            // is optimistically updated. This condition is only to update
            // the state if user clicks on save from web view
            if (state.status == SavedItemsStatus.success &&
                state.currentItemId == _item.id &&
                _item.isSaved != (state.action == SavedItemsAction.save)) {
              _updateItem(
                _item.copyWith(
                  isSaved: state.action == SavedItemsAction.save,
                ),
              );
            }
          },
        ),
        BlocListener<LikedItemsBloc, LikedItemsState>(
          listener: (context, state) {
            if (state.status == LikedItemsStatus.failure &&
                state.currentItemId == _item.id &&
                (state.action == LikedItemsAction.unlike ||
                    state.action == LikedItemsAction.like)) {
              _updateItem(
                // if the failed action is like, then set isLiked to false
                // by comparing with unlike
                _item.copyWith(
                  isLiked: state.action == LikedItemsAction.unlike,
                ),
              );
            }

            // when user clicks on like button from list tile, the state
            // is optimistically updated. This condition is only to update
            // the state if user clicks on like from web view
            if (state.status == LikedItemsStatus.success &&
                state.currentItemId == _item.id &&
                _item.isLiked != (state.action == LikedItemsAction.like)) {
              _updateItem(
                _item.copyWith(
                  isLiked: state.action == LikedItemsAction.like,
                ),
              );
            }
          },
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.pagePadding,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 0.5,
                      color: context.theme.colorScheme.onSurface.withAlpha(50),
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(context),
                    _buildActionStrip(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          RouteConstants.webViewPageName,
          queryParameters: {
            'url': _item.link,
            'itemId': _item.id.toString(),
            'isSaved': _item.isSaved.toString(),
            'isLiked': _item.isLiked.toString(),
          },
        );
      },
      splashColor: Colors.transparent,
      child: AutoSizeText(
        _item.title[0].trimLeft().toUpperCase() + _item.title.substring(1),
        style: context.theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        minFontSize: 17,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildActionStrip(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
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
                _item.isLiked ? Icons.favorite : Icons.favorite_border,
                iconSize: 20,
                extraPaddingBottom: 0,
                iconColor: _item.isLiked ? Colors.red : null,
                () {
                  context.read<LikedItemsBloc>().add(
                        _item.isLiked
                            ? UnlikeItemRequested(
                                itemId: _item.id,
                                refresh: true,
                              )
                            : LikeItemRequested(_item.id),
                      );

                  // Track item liked event
                  if (!_item.isLiked) {
                    AnalyticsService.logItemLiked('${_item.id}');
                  }

                  _updateItem(
                    _item.copyWith(
                      isLiked: !_item.isLiked,
                    ),
                  );
                },
              ),
              _buildActionButton(
                context,
                _item.isSaved ? MingCute.bookmark_fill : MingCute.bookmark_line,
                iconSize: 19,
                extraPaddingBottom: 1,
                iconColor: _item.isSaved ? AppPalette.savedAmber : null,
                () {
                  context.read<SavedItemsBloc>().add(
                        _item.isSaved
                            ? UnsaveItemRequested(
                                itemId: _item.id, refresh: true)
                            : SaveItemRequested(_item.id),
                      );

                  // Track item saved event
                  if (!_item.isSaved) {
                    AnalyticsService.logItemSaved('${_item.id}');
                  }

                  _updateItem(
                    _item.copyWith(
                      isSaved: !_item.isSaved,
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
                  AnalyticsService.logItemShared('${_item.id}');

                  try {
                    final result = await SharePlus.instance.share(
                      ShareParams(
                        text:
                            'Hey, check this out!\n\n${_item.link}\n\n_shared via *Semaphore* app_',
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
    if (_item.feed != null) {
      final feed = _item.feed!;
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
                  color: context.theme.colorScheme.onSurface.withAlpha(178)),
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
                color: context.theme.colorScheme.onSurface.withAlpha(178)),
          ),
        Text(
          formatPublishedDateAlt(
            _item.pubUpdated ?? _item.pubDate ?? _item.createdAt,
          ),
          style: context.theme.textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w300,
              color: context.theme.colorScheme.onSurface.withAlpha(178)),
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
