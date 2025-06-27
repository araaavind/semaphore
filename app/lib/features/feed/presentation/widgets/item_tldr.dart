import 'dart:ui';

import 'package:app/core/common/widgets/item_cached_image.dart';
import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/services/analytics_service.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/icons/mingcute.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ItemTLDR extends StatelessWidget {
  final Item item;
  const ItemTLDR({
    required this.item,
    super.key,
  });

  Widget? get content {
    // TODO: Add AI summary
    if (item.content == null) {
      return null;
    }
    return Html(
      data: item.content!,
      doNotRenderTheseTags: Set.from(['a', 'img']),
    );
  }

  void _showItemPreview(BuildContext context) {
    AnalyticsService.logTLDROpened(item.link.toString());

    showDialog(
      context: context,
      barrierColor: context.theme.colorScheme.surface.withAlpha(180),
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: UIConstants.pagePadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              UIConstants.imageBorderRadius,
            ),
            side: BorderSide.none,
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 350,
                maxHeight: 500,
              ),
              foregroundDecoration: BoxDecoration(color: Colors.transparent),
              decoration: BoxDecoration(
                color: context.theme.brightness == Brightness.dark
                    ? context.theme.colorScheme.surfaceContainerLowest
                    : context.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(
                  UIConstants.imageBorderRadius,
                ),
                border: Border.all(
                  color: context.theme.colorScheme.onSurface.withAlpha(80),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Image section
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: ItemCachedImage(
                            item: item,
                            height: 200,
                            width: 350,
                          ),
                        ),
                        // Title section
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 10,
                            bottom: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Summarized by ',
                                        ),
                                        TextSpan(
                                          text: 'tldrify.link',
                                          style: context
                                              .theme.textTheme.labelMedium
                                              ?.copyWith(
                                            color: context
                                                .theme.colorScheme.onSurface
                                                .withAlpha(140),
                                            fontWeight: FontWeight.w500,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                    style: context.theme.textTheme.labelMedium
                                        ?.copyWith(
                                      color: context.theme.colorScheme.onSurface
                                          .withAlpha(80),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.title[0].trimLeft().toUpperCase() +
                                    item.title.substring(1),
                                style:
                                    context.theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (content != null) const SizedBox(height: 14),
                              if (content != null) content!,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(120),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.all(3.0),
                        child: Icon(
                          Icons.close,
                          size: 17,
                          color: context.theme.colorScheme.onSurface
                              .withAlpha(160),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          UIConstants.imageBorderRadius,
                        ),
                        gradient: LinearGradient(
                          colors: [
                            context.theme.colorScheme.surfaceContainerLowest
                                .withAlpha(245),
                            context.theme.colorScheme.surfaceContainerLowest
                                .withAlpha(0),
                          ],
                          stops: const [0.05, 1.0],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!UIConstants.tldrEnabled) {
      return const SizedBox.shrink();
    }
    return AnimatedIconButton(
      padding: EdgeInsets.only(left: 5.0, right: 3.0),
      onPressed: () => _showItemPreview(context),
      icon: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (Rect bounds) => LinearGradient(
          colors: [
            Colors.blueAccent.withAlpha(200).withBlue(180),
            Colors.deepPurple.withAlpha(200).withBlue(180),
          ],
        ).createShader(bounds),
        child: Icon(
          MingCute.ai_line,
          size: 20,
        ),
      ),
    );
  }
}
