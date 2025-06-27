import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/item.dart';
import 'package:app/features/feed/presentation/bloc/liked_items/liked_items_bloc.dart';
import 'package:app/features/feed/presentation/bloc/saved_items/saved_items_bloc.dart';
import 'package:app/features/feed/presentation/widgets/item_list_tile_action_strip.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
                    ItemListTileActionStrip(
                      item: _item,
                      onItemUpdated: _updateItem,
                      paddingTop: 6.0,
                    ),
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
}
