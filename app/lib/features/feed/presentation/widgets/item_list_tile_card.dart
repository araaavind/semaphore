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

class ItemListTileCard extends StatelessWidget {
  final Item item;
  final PagingController<int, Item> _pagingController;
  const ItemListTileCard({
    required this.item,
    required PagingController<int, Item> pagingController,
    super.key,
  }) : _pagingController = pagingController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          RouteConstants.webViewPageName,
          queryParameters: {'url': item.link},
        );
      },
      child: Card(
        margin: EdgeInsets.zero,
        color: context.theme.colorScheme.surface,
        shape: Border.symmetric(
          horizontal: BorderSide(
            color: context.theme.colorScheme.outline,
            width: 0.25,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.pagePadding,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post header: Subreddit name, posted by username
              Row(
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
                            'listItemsBlocValue':
                                BlocProvider.of<ListItemsBloc>(context),
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
                              color: context.theme.colorScheme.onSurface
                                  .withOpacity(0.7)),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ),
                  if (item.feed?.title != null && item.feed!.title.isNotEmpty)
                    Text(
                      '   •   ',
                      style: context.theme.textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w300,
                          color: context.theme.colorScheme.onSurface
                              .withOpacity(0.7)),
                    ),
                  Text(
                    formatPublishedDate(
                      item.pubUpdated ?? item.pubDate ?? item.createdAt,
                    ),
                    style: context.theme.textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w300,
                        color: context.theme.colorScheme.onSurface
                            .withOpacity(0.7)),
                  ),
                ],
              ),
              const SizedBox(height: 6.0),
              // Post title
              AutoSizeText(
                item.title[0].toUpperCase() + item.title.substring(1),
                style: context.theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                minFontSize: context.theme.textTheme.bodyLarge!.fontSize!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6.0),
              ItemCachedImage(
                item: item,
                height: 180,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
