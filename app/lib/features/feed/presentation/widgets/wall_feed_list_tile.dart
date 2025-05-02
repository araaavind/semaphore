import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:app/features/feed/presentation/bloc/wall_feed/wall_feed_bloc.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class WallFeedListTile extends StatefulWidget {
  final Feed feed;
  final int wallId;
  final Function() onRemove;

  const WallFeedListTile({
    required this.feed,
    required this.wallId,
    required this.onRemove,
    super.key,
  });

  @override
  State<WallFeedListTile> createState() => _WallFeedListTileState();
}

class _WallFeedListTileState extends State<WallFeedListTile> {
  late final Feed feed;
  bool isRemoved = false;

  @override
  void initState() {
    super.initState();
    feed = widget.feed;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WallFeedBloc, WallFeedState>(
      listener: (context, state) {
        if (state is WallFeedFailure &&
            (state.action == WallFeedAction.remove ||
                state.action == WallFeedAction.add) &&
            state.feedId == feed.id) {
          showSnackbar(
            context,
            state.message,
            type: SnackbarType.failure,
          );
        }
        if (state is WallFeedSuccess &&
            state.feedId == feed.id &&
            state.action == WallFeedAction.remove) {
          widget.onRemove();
          context.read<WallsBloc>().add(ListWallsRequested());
        }
      },
      builder: (context, state) {
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
            onTap: () async {
              // final Map<String, Object> extra = {
              //   'feed': feed,
              //   'followFeedBlocValue':
              //       BlocProvider.of<FollowFeedBloc>(context),
              //   'listItemsBlocValue':
              //       BlocProvider.of<ListItemsBloc>(context),
              //   'isFollowed': true,
              // };
              // final unfollowed = await context.pushNamed(
              //   RouteConstants.feedViewPageName,
              //   pathParameters: {'feedId': feed.id.toString()},
              //   extra: extra,
              // );
              // if (unfollowed != null && unfollowed == true) {
              //   setState(() {
              //     isRemoved = true;
              //   });
              // }
            },
            splashColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              vertical: UIConstants.tileContentPadding,
              horizontal: UIConstants.pagePadding,
            ),
            title: AutoSizeText(
              feed.title.isNotEmpty ? feed.title.toTitleCase() : 'Feed',
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
            leading: state is WallFeedLoading &&
                    state.action == WallFeedAction.remove &&
                    state.feedId == feed.id
                ? SizedBox(
                    height: 24.0,
                    width: 24.0,
                    child: SpinKitDualRing(
                      size: 18.0,
                      lineWidth: 3.0,
                      duration: const Duration(milliseconds: 400),
                      color:
                          context.theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  )
                : Container(
                    height: 24.0,
                    width: 24.0,
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: Icon(
                        MingCute.minus_circle_line,
                        size: 24.0,
                        weight: 0.4,
                        color: context.theme.colorScheme.onSurface
                            .withOpacity(0.70),
                      ),
                      onPressed: () {
                        context.read<WallFeedBloc>().add(
                              RemoveFeedFromWallRequested(
                                feedId: feed.id,
                                wallId: widget.wallId,
                              ),
                            );
                      },
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
