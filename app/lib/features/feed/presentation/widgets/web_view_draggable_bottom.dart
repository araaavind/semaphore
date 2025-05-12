import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class WebViewDraggableBottom extends StatefulWidget {
  final InAppWebViewController? webViewController;
  const WebViewDraggableBottom({
    super.key,
    this.webViewController,
  });

  @override
  State<WebViewDraggableBottom> createState() => _WebViewDraggableBottomState();
}

class _WebViewDraggableBottomState extends State<WebViewDraggableBottom> {
  // Default drawer snap points
  static const List<double> snapPoints = [0.08];

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
                color: Colors.black.withOpacity(0.1),
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
                    const SizedBox(height: 16),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildActionButton(
            context,
            MingCute.arrow_left_line,
            () {
              context.pop();
            },
          ),
          _buildActionButton(
            context,
            MingCute.refresh_1_line,
            () {
              widget.webViewController?.reload();
            },
          ),
          _buildActionButton(
            context,
            MingCute.share_2_line,
            () async {
              if (widget.webViewController != null) {
                final url = await widget.webViewController!.getUrl();
                if (url != null) {
                  try {
                    final result = await SharePlus.instance.share(
                      ShareParams(
                        text: 'Check out this article: ${url.toString()}',
                      ),
                    );

                    if (result.status != ShareResultStatus.success &&
                        context.mounted) {
                      showSnackbar(context, 'Failed to share article',
                          type: SnackbarType.failure);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      showSnackbar(context, 'Failed to share article',
                          type: SnackbarType.failure);
                    }
                  }
                }
              }
            },
          ),
          // _buildActionButton(
          //   context,
          //   MingCute.bookmark_line,
          //   () {},
          // ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Icon(
        icon,
        size: 24,
        color: context.theme.colorScheme.onSurface.withOpacity(0.9),
      ),
    );
  }
}
