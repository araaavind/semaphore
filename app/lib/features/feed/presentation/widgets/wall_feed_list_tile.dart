import 'package:app/core/common/cubits/network/network_cubit.dart';
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
          context.read<WallsBloc>().add(ListWallsRequested(refreshItems: true));
        }
      },
      builder: (context, state) {
        String title = 'Feed';
        if (feed.displayTitle != null && feed.displayTitle!.isNotEmpty) {
          title = feed.displayTitle!;
        } else if (feed.title.isNotEmpty) {
          title = feed.title;
        }

        // Convert HTML to plain text
        final plainTextDescription =
            HtmlUtils.htmlToPlainText(feed.description);
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
              title,
              style: context.theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w600,
              ),
              minFontSize: context.theme.textTheme.bodyLarge!.fontSize!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: plainTextDescription.isNotEmpty
                ? AutoSizeText(
                    plainTextDescription,
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
                      color: context.theme.colorScheme.onSurface.withAlpha(178),
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
                        color:
                            context.theme.colorScheme.onSurface.withAlpha(178),
                      ),
                      onPressed: () async {
                        if (context.read<NetworkCubit>().state.status ==
                            NetworkStatus.disconnected) {
                          showSnackbar(
                            context,
                            'No internet connection',
                            type: SnackbarType.failure,
                          );
                          return;
                        }
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            contentPadding: const EdgeInsets.only(
                              top: 36.0,
                              left: 32.0,
                              right: 24.0,
                              bottom: 24.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            backgroundColor: context.theme.colorScheme.surface,
                            content: Text.rich(
                              TextSpan(
                                style: context.theme.textTheme.bodyLarge,
                                children: [
                                  const TextSpan(
                                      text:
                                          'Are you sure you want to remove this feed from the wall?'),
                                  TextSpan(
                                    text: '\n\n(This action cannot be undone.)',
                                    style: context.theme.textTheme.bodySmall!
                                        .copyWith(
                                      fontWeight: FontWeight.w100,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text(
                                  'Cancel',
                                  style: context.theme.textTheme.titleMedium!
                                      .copyWith(
                                    color: context.theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(
                                  'Yes',
                                  style: context.theme.textTheme.titleMedium!
                                      .copyWith(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          context.read<WallFeedBloc>().add(
                                RemoveFeedFromWallRequested(
                                  feedId: feed.id,
                                  wallId: widget.wallId,
                                ),
                              );
                        }
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
