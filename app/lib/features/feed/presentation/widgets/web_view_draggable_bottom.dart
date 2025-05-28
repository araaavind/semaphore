import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/presentation/bloc/liked_items/liked_items_bloc.dart';
import 'package:app/features/feed/presentation/bloc/saved_items/saved_items_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class WebViewDraggableBottom extends StatefulWidget {
  final InAppWebViewController? webViewController;
  final int itemId;
  final bool isSaved;
  final bool isLiked;
  const WebViewDraggableBottom({
    super.key,
    this.webViewController,
    required this.itemId,
    this.isSaved = false,
    this.isLiked = false,
  });

  @override
  State<WebViewDraggableBottom> createState() => _WebViewDraggableBottomState();
}

class _WebViewDraggableBottomState extends State<WebViewDraggableBottom> {
  // Default drawer snap points
  static const List<double> snapPoints = [0.08];
  bool isSaved = false;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    isSaved = widget.isSaved;
    isLiked = widget.isLiked;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: snapPoints.first, // Start with the smallest size
      minChildSize: snapPoints.first,
      maxChildSize: snapPoints.last,
      snap: true,
      snapSizes: snapPoints,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 3,
                spreadRadius: 0,
                offset: const Offset(0.5, 0.5),
              ),
            ],
            border: (context.theme.colorScheme.brightness == Brightness.dark)
                ? Border(
                    top: BorderSide(
                      color: context.theme.colorScheme.outline,
                      width: UIConstants.borderWidth,
                    ),
                  )
                : null,
          ),
          child: Column(
            children: [
              // Drawer content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // const SizedBox(height: 10),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   crossAxisAlignment: CrossAxisAlignment.center,
                    //   children: [
                    //     // Drawer handle/grip
                    //     Container(
                    //       height: 4.5,
                    //       width: 60,
                    //       decoration: BoxDecoration(
                    //         color: context.theme.colorScheme.onSurface
                    //             .withOpacity(0.45),
                    //         borderRadius: BorderRadius.circular(2.5),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    _buildActionRow(context),
                    // Add more sections as needed
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildActionButton(
          context,
          Icons.arrow_back_sharp,
          () {
            context.pop();
          },
        ),
        _buildLikeButton(context),
        _buildSaveButton(context),
        _buildShareButton(context),
      ],
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return _buildActionButton(
      context,
      animateOnTap: false,
      MingCute.share_2_line,
      iconSize: 25,
      extraPaddingBottom: 1,
      () async {
        if (widget.webViewController != null) {
          final url = await widget.webViewController!.getUrl();
          if (url != null) {
            try {
              final result = await SharePlus.instance.share(
                ShareParams(
                  text:
                      'Hey, check this out!\n\n${url.toString()}\n\n_shared via *Semaphore* app_',
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
          }
        }
      },
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return BlocListener<SavedItemsBloc, SavedItemsState>(
      listener: (context, state) {
        if (state.status == SavedItemsStatus.failure &&
            (state.action == SavedItemsAction.unsave ||
                state.action == SavedItemsAction.save)) {
          setState(() {
            // if the failed action is unsave, then set isSaved to true
            isSaved = state.action == SavedItemsAction.unsave;
          });
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
      },
      child: _buildActionButton(
        context,
        isSaved ? MingCute.bookmark_fill : MingCute.bookmark_line,
        iconSize: 24.5,
        iconColor: isSaved ? AppPalette.savedAmber : null,
        extraPaddingBottom: 1,
        () {
          context.read<SavedItemsBloc>().add(
                isSaved
                    ? UnsaveItemRequested(itemId: widget.itemId, refresh: true)
                    : SaveItemRequested(widget.itemId),
              );
          setState(() {
            isSaved = !isSaved;
          });
        },
      ),
    );
  }

  Widget _buildLikeButton(BuildContext context) {
    return BlocListener<LikedItemsBloc, LikedItemsState>(
      listener: (context, state) {
        if (state.status == LikedItemsStatus.failure &&
            (state.action == LikedItemsAction.unlike ||
                state.action == LikedItemsAction.like)) {
          setState(() {
            // if the failed action is unlike, then set isLiked to true
            isLiked = state.action == LikedItemsAction.unlike;
          });
        }
      },
      child: _buildActionButton(
        context,
        isLiked ? Icons.favorite : Icons.favorite_border,
        () {
          context.read<LikedItemsBloc>().add(
                isLiked
                    ? UnlikeItemRequested(
                        itemId: widget.itemId,
                        refresh: true,
                      )
                    : LikeItemRequested(widget.itemId),
              );
          setState(() {
            isLiked = !isLiked;
          });
        },
        iconColor: isLiked ? Colors.red : null,
      ),
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
        size: iconSize ?? 26,
        color: iconColor?.withAlpha(229) ??
            context.theme.colorScheme.onSurface.withAlpha(229),
      ),
      padding: EdgeInsets.only(
        bottom: 14 + (extraPaddingBottom ?? 0),
        left: 24,
        right: 24,
        top: 16,
      ),
      onPressed: onPressed,
      animateOnTap: animateOnTap,
    );
  }
}
