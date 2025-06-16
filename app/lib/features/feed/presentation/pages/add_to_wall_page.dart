import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/feed/domain/entities/wall.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:app/features/feed/presentation/bloc/wall_feed/wall_feed_bloc.dart';
import 'package:app/core/utils/utils.dart';

class AddToWallPage extends StatefulWidget {
  final int feedId;

  const AddToWallPage({super.key, required this.feedId});

  @override
  State<AddToWallPage> createState() => _AddToWallPageState();
}

class _AddToWallPageState extends State<AddToWallPage> {
  bool listUpdated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add to wall',
          style: context.theme.textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: UIConstants.defaultAppBarTextButtonPadding,
            child: TextButton(
              onPressed: () => context.pushNamed(
                RouteConstants.createWallPageName,
                queryParameters: {"feedId": widget.feedId.toString()},
              ),
              style: const ButtonStyle(
                splashFactory: NoSplash.splashFactory,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Icon(
                      MingCute.add_fill,
                      size: 18.0,
                      color: context.theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    'New wall',
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<WallFeedBloc, WallFeedState>(
        listener: (context, state) {
          if (state is WallFeedFailure &&
              (state.action == WallFeedAction.add ||
                  state.action == WallFeedAction.remove)) {
            showSnackbar(context, state.message, type: SnackbarType.failure);
          }
        },
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: UIConstants.pagePadding),
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              Button(
                text: 'Unfollow feed',
                width: double.infinity,
                filled: true,
                backgroundColor: context.theme.colorScheme.primaryContainer,
                textColor: context.theme.colorScheme.onPrimaryContainer,
                onPressed: () {
                  context.pop({"unfollow": true});
                },
              ),
              const SizedBox(height: 20.0),
              Expanded(
                child: BlocBuilder<WallsBloc, WallsState>(
                  builder: (context, state) {
                    if (state.status == WallStatus.loading) {
                      return const Padding(
                        padding: EdgeInsets.all(UIConstants.pagePadding),
                        child: ShimmerLoader(
                          pageSize: 8,
                          type: ShimmerLoaderType.lines,
                        ),
                      );
                    } else if (state.status == WallStatus.failure) {
                      return SizedBox(
                        width: 300,
                        child: Center(
                            child:
                                Text(state.message ?? 'Failed to load walls')),
                      );
                    } else if (state.walls.isEmpty) {
                      return const Center(child: Text('No walls found'));
                    }
                    return ListView.builder(
                      itemCount: state.walls.length,
                      itemBuilder: (context, index) {
                        final wall = state.walls[index];
                        if (wall.isPrimary) {
                          return const SizedBox.shrink();
                        }
                        return WallListTile(
                          wall: wall,
                          feedId: widget.feedId,
                          onListUpdated: (isFeedInWall) {
                            setState(() {
                              listUpdated = isFeedInWall;
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20.0),
              Button(
                text: 'Done',
                onPressed: () {
                  context.pop({"unfollow": false, "listUpdated": listUpdated});
                },
              ),
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }
}

class WallListTile extends StatefulWidget {
  final Wall wall;
  final int feedId;
  final Function(bool) onListUpdated;

  const WallListTile({
    super.key,
    required this.wall,
    required this.feedId,
    required this.onListUpdated,
  });

  @override
  State<WallListTile> createState() => _WallListTileState();
}

class _WallListTileState extends State<WallListTile> {
  late bool isFeedInWall;

  @override
  void initState() {
    super.initState();
    isFeedInWall =
        widget.wall.feeds?.any((feed) => feed.id == widget.feedId) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WallFeedBloc, WallFeedState>(
      listenWhen: (previous, current) =>
          current is WallFeedSuccess &&
          (current.action == WallFeedAction.add ||
              current.action == WallFeedAction.remove) &&
          current.wallId == widget.wall.id,
      listener: (context, state) {
        if (state is WallFeedSuccess &&
            (state.action == WallFeedAction.add ||
                state.action == WallFeedAction.remove) &&
            state.wallId == widget.wall.id) {
          setState(() {
            isFeedInWall = !isFeedInWall;
          });
          widget.onListUpdated(true);
        }
      },
      buildWhen: (previous, current) =>
          current is WallFeedLoading &&
              (current.action == WallFeedAction.add ||
                  current.action == WallFeedAction.remove) &&
              current.wallId == widget.wall.id ||
          current is WallFeedSuccess &&
              (current.action == WallFeedAction.add ||
                  current.action == WallFeedAction.remove) &&
              current.wallId == widget.wall.id ||
          current is WallFeedFailure &&
              (current.action == WallFeedAction.add ||
                  current.action == WallFeedAction.remove) &&
              current.wallId == widget.wall.id,
      builder: (context, state) {
        final bool isLoading = state is WallFeedLoading &&
            (state.action == WallFeedAction.add ||
                state.action == WallFeedAction.remove) &&
            state.wallId == widget.wall.id;

        return ListTile(
          visualDensity: VisualDensity.standard,
          dense: true,
          title: AutoSizeText(
            widget.wall.name,
            style: context.theme.textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.w600,
            ),
            minFontSize: context.theme.textTheme.bodyLarge!.fontSize!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: UIConstants.tileContentPadding,
            horizontal: UIConstants.pagePadding,
          ),
          horizontalTitleGap: UIConstants.tileHorizontalTitleGap,
          trailing: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isLoading
                ? SizedBox(
                    height: 28.0,
                    width: 28.0,
                    child: isFeedInWall
                        ? SpinKitDualRing(
                            size: 21.0,
                            lineWidth: 3.0,
                            duration: const Duration(milliseconds: 400),
                            color: context.theme.colorScheme.onSurface,
                          )
                        : SpinKitHourGlass(
                            size: 23.0,
                            duration: const Duration(milliseconds: 2400),
                            color: context.theme.colorScheme.primary,
                          ),
                  )
                : Container(
                    height: 28.0,
                    width: 28.0,
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                              scale: animation, child: child);
                        },
                        child: Icon(
                          isFeedInWall
                              ? MingCute.check_circle_line
                              : MingCute.add_circle_line,
                          color: isFeedInWall
                              ? context.theme.colorScheme.primary
                              : context.theme.colorScheme.onSurface,
                          size: 28.0,
                        ),
                      ),
                      onPressed: () {
                        if (isFeedInWall) {
                          context
                              .read<WallFeedBloc>()
                              .add(RemoveFeedFromWallRequested(
                                feedId: widget.feedId,
                                wallId: widget.wall.id,
                              ));
                        } else {
                          context
                              .read<WallFeedBloc>()
                              .add(AddFeedToWallRequested(
                                feedId: widget.feedId,
                                wallId: widget.wall.id,
                              ));
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
