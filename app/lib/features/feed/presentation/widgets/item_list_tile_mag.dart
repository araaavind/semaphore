import 'package:app/core/common/widgets/item_cached_image.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/item.dart';
import 'package:app/features/feed/presentation/bloc/liked_items/liked_items_bloc.dart';
import 'package:app/features/feed/presentation/bloc/saved_items/saved_items_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ItemListTileMag extends StatefulWidget {
  final Item item;
  final bool isTextOnly;
  const ItemListTileMag({
    required this.item,
    this.isTextOnly = false,
    super.key,
  });

  @override
  State<ItemListTileMag> createState() => _ItemListTileMagState();
}

class _ItemListTileMagState extends State<ItemListTileMag> {
  late Item _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SavedItemsBloc, SavedItemsState>(
          listener: (context, state) {
            if (state.status == SavedItemsStatus.success &&
                state.currentItemId == _item.id) {
              setState(() {
                _item = _item.copyWith(
                  isSaved: state.action == SavedItemsAction.save,
                );
              });
            }
          },
        ),
        BlocListener<LikedItemsBloc, LikedItemsState>(
          listener: (context, state) {
            if (state.status == LikedItemsStatus.success &&
                state.currentItemId == _item.id) {
              setState(() {
                _item = _item.copyWith(
                  isLiked: state.action == LikedItemsAction.like,
                );
              });
            }
          },
        ),
      ],
      child: InkWell(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: UIConstants.pagePadding,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.isTextOnly)
                ItemCachedImage(item: _item, height: 90, width: 100),
              if (!widget.isTextOnly)
                const SizedBox(width: UIConstants.tileHorizontalTitleGap),
              Expanded(
                child: SizedBox(
                  height: 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AutoSizeText(
                        _item.title[0].toUpperCase() + _item.title.substring(1),
                        style: context.theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        minFontSize: 16,
                        maxLines: 3,
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
}
