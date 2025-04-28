import 'package:app/core/common/widgets/item_cached_image.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/item.dart';
import 'package:app/features/feed/presentation/bloc/follow_feed/follow_feed_bloc.dart';
import 'package:app/features/feed/presentation/bloc/list_items/list_items_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ItemListTileMag extends StatelessWidget {
  final Item item;
  final PagingController<int, Item> _pagingController;
  final bool isTextOnly;
  const ItemListTileMag({
    required this.item,
    required PagingController<int, Item> pagingController,
    this.isTextOnly = false,
    super.key,
  }) : _pagingController = pagingController;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
      splashColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: UIConstants.pagePadding,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isTextOnly)
              ItemCachedImage(item: item, height: 90, width: 100),
            if (!isTextOnly)
              const SizedBox(width: UIConstants.tileHorizontalTitleGap),
            Expanded(
              child: SizedBox(
                height: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoSizeText(
                      item.title[0].toUpperCase() + item.title.substring(1),
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
    );
  }

  Row _buildSubtitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (item.feed?.title != null && item.feed!.title.isNotEmpty)
          Flexible(
            child: InkWell(
              onTap: () async {
                final Map<String, Object> extra = {
                  'feed': item.feed!,
                  'followFeedBlocValue':
                      BlocProvider.of<FollowFeedBloc>(context),
                  'listItemsBlocValue': BlocProvider.of<ListItemsBloc>(context),
                  'isFollowed': true,
                };
                final unfollowed = await context.pushNamed(
                  RouteConstants.feedViewPageName,
                  pathParameters: {
                    'feedId': item.feed!.id.toString(),
                  },
                  extra: extra,
                );
                if ((unfollowed as bool) == true) {
                  _pagingController.refresh();
                }
              },
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
          ),
        if ((item.feed?.title != null && item.feed!.title.isNotEmpty))
          Text(
            '  •  ',
            style: context.theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w300,
                color: context.theme.colorScheme.onSurface.withOpacity(0.7)),
          ),
        Text(
          formatPublishedDate(
            item.pubUpdated ?? item.pubDate ?? item.createdAt,
          ),
          style: context.theme.textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w300,
              color: context.theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
      ],
    );
  }
}
