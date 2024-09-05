import 'dart:math';

import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/feed/utils/extract_best_image_url.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/item.dart';
import 'package:app/features/feed/presentation/bloc/follow_feed/follow_feed_bloc.dart';
import 'package:app/features/feed/presentation/bloc/list_items/list_items_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shimmer/shimmer.dart';

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
                  if ((item.feed?.title != null &&
                          item.feed!.title.isNotEmpty) &&
                      (item.pubDate != null || item.pubUpdated != null))
                    Text(
                      '   •   ',
                      style: context.theme.textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w300,
                          color: context.theme.colorScheme.onSurface
                              .withOpacity(0.7)),
                    ),
                  if (item.pubDate != null || item.pubUpdated != null)
                    Text(
                      formatPublishedDate(
                        item.pubUpdated ?? item.pubDate ?? DateTime.now(),
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
                item.title.toTitleCase(),
                style: context.theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                minFontSize: context.theme.textTheme.bodyLarge!.fontSize!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6.0),
              _buildCardBody(),
            ],
          ),
        ),
      ),
    );
  }

  FutureBuilder<List<String>> _buildCardBody() {
    return FutureBuilder(
      future: getItemImageUrls(
        item,
        includeFavicon: false,
        scrapeFromLink: true,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          final url = snapshot.data!.firstWhere(
            (url) => !url.contains('.svg'),
            orElse: () => snapshot.data!.first,
          );
          return CachedNetworkImage(
            imageUrl: url,
            imageBuilder: (context, imageProvider) => Container(
              height: 180.0,
              decoration: BoxDecoration(
                color: context.theme.colorScheme.primaryContainer,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: imageProvider,
                ),
                borderRadius: BorderRadius.circular(
                  UIConstants.cardImageBorderRadius,
                ),
              ),
            ),
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: context.theme.colorScheme.primary.withAlpha(30),
              highlightColor: context.theme.colorScheme.primary.withAlpha(65),
              child: Container(
                height: 180.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    UIConstants.cardImageBorderRadius,
                  ),
                  color: Colors.white,
                ),
              ),
            ),
            errorWidget: (context, url, error) => _buildNoImageWidget(context),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: context.theme.colorScheme.primary.withAlpha(30),
            highlightColor: context.theme.colorScheme.primary.withAlpha(65),
            child: Container(
              height: 180.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  UIConstants.cardImageBorderRadius,
                ),
                color: Colors.white,
              ),
            ),
          );
        }
        return _buildNoImageWidget(context);
      },
    );
  }
}

Widget _buildNoImageWidget(BuildContext context) {
  final random = Random();
  final hue = random.nextDouble() * 360;
  final color = HSLColor.fromAHSL(
    0.4, // Alpha
    hue, // Random Hue
    0.4, // Low Saturation (40%)
    0.8, // High Lightness (80%)
  ).toColor();
  return Container(
    height: 180.0,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(UIConstants.cardImageBorderRadius),
      color: color,
    ),
    child: Center(
      child: Text(
        'SMPHR',
        style: context.theme.textTheme.titleLarge!.copyWith(
          color: context.theme.colorScheme.surface.withAlpha(180),
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}
