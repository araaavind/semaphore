import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/feed/utils/extract_best_image_url.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/item.dart';
import 'package:app/features/feed/presentation/bloc/follow_feed/follow_feed_bloc.dart';
import 'package:app/features/feed/presentation/bloc/list_items/list_items_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math';

class ItemListTileMag extends StatefulWidget {
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
  State<ItemListTileMag> createState() => _ItemListTileMagState();
}

class _ItemListTileMagState extends State<ItemListTileMag> {
  String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final String routeName = GoRouterState.of(context).topRoute!.name!;
        if (routeName == RouteConstants.wallPageName) {
          context.goNamed(
            'webview',
            queryParameters: {'url': widget.item.link},
          );
        } else if (routeName == RouteConstants.feedViewPageName) {
          context.goNamed(
            'feed-webview',
            queryParameters: {'url': widget.item.link},
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
            if (!widget.isTextOnly) _buildMagImage(),
            if (!widget.isTextOnly)
              const SizedBox(width: UIConstants.tileHorizontalTitleGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    widget.item.title[0].toUpperCase() +
                        widget.item.title.substring(1),
                    style: context.theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    minFontSize: context.theme.textTheme.bodyLarge!.fontSize!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _buildSubtitle(context),
                ],
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
        if (widget.item.feed?.title != null &&
            widget.item.feed!.title.isNotEmpty)
          Flexible(
            child: InkWell(
              onTap: () async {
                final Map<String, Object> extra = {
                  'feed': widget.item.feed!,
                  'followFeedBlocValue':
                      BlocProvider.of<FollowFeedBloc>(context),
                  'listItemsBlocValue': BlocProvider.of<ListItemsBloc>(context),
                  'isFollowed': true,
                };
                final unfollowed = await context.pushNamed(
                  RouteConstants.feedViewPageName,
                  pathParameters: {
                    'feedId': widget.item.feed!.id.toString(),
                  },
                  extra: extra,
                );
                if ((unfollowed as bool) == true) {
                  widget._pagingController.refresh();
                }
              },
              child: AutoSizeText(
                widget.item.feed!.title,
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
        if ((widget.item.feed?.title != null &&
            widget.item.feed!.title.isNotEmpty))
          Text(
            '   •   ',
            style: context.theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w300,
                color: context.theme.colorScheme.onSurface.withOpacity(0.7)),
          ),
        Text(
          formatPublishedDate(
            widget.item.pubUpdated ??
                widget.item.pubDate ??
                widget.item.createdAt,
          ),
          style: context.theme.textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w300,
              color: context.theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
      ],
    );
  }

  FutureBuilder<List<String>> _buildMagImage() {
    return FutureBuilder(
      future: getItemImageUrls(widget.item),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          final url = imageUrl ??
              snapshot.data!.firstWhere(
                (url) => !url.contains('.svg'),
                orElse: () => snapshot.data!.first,
              );
          return CachedNetworkImage(
            memCacheWidth: 100 * View.of(context).devicePixelRatio.ceil(),
            memCacheHeight: 80 * View.of(context).devicePixelRatio.ceil(),
            maxWidthDiskCache: 100 * View.of(context).devicePixelRatio.ceil(),
            maxHeightDiskCache: 80 * View.of(context).devicePixelRatio.ceil(),
            width: 100.0,
            height: 80.0,
            imageUrl: url,
            imageBuilder: (context, imageProvider) => Container(
              width: 100.0,
              height: 80.0,
              foregroundDecoration: BoxDecoration(
                color:
                    context.theme.colorScheme.primaryContainer.withAlpha(100),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: imageProvider,
                ),
                borderRadius:
                    BorderRadius.circular(UIConstants.magImageBorderRadius),
              ),
              child: _buildNoImageWidget(context),
            ),
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: context.theme.colorScheme.primary.withAlpha(30),
              highlightColor: context.theme.colorScheme.primary.withAlpha(65),
              child: Container(
                width: 100.0,
                height: 80.0,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(UIConstants.magImageBorderRadius),
                  color: Colors.white,
                ),
              ),
            ),
            errorWidget: (context, url, error) {
              return _buildNoImageWidget(context);
            },
            errorListener: (e) {
              if (kDebugMode) {
                print('Error listener for widget ${widget.item.title}: $e');
              }
              if (imageUrl == null) {
                for (var url in snapshot.data!) {
                  if (url != snapshot.data!.first && !url.contains('.svg')) {
                    setState(() {
                      imageUrl = url;
                    });
                    break;
                  }
                }
              }
            },
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: context.theme.colorScheme.primary.withAlpha(30),
            highlightColor: context.theme.colorScheme.primary.withAlpha(65),
            child: Container(
              width: 100.0,
              height: 80.0,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(UIConstants.magImageBorderRadius),
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
    height: 80.0,
    width: 100.0,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(UIConstants.magImageBorderRadius),
      color: color,
    ),
    child: Center(
      child: Text(
        'SMPHR',
        style: context.theme.textTheme.bodySmall!.copyWith(
          color: context.theme.colorScheme.surface.withAlpha(180),
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}
