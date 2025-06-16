import 'dart:math';

import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/features/feed/domain/entities/topic.dart';
import 'package:app/features/feed/presentation/bloc/topics/topics_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopicsGrid extends StatelessWidget {
  final Function(Topic, Color) onTap;

  const TopicsGrid({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicsBloc, TopicsState>(
      builder: (context, state) {
        if (state.status == TopicsStatus.initial) {
          return const SizedBox.shrink();
        }
        // Do not show loader for remote fetch
        if (state.status == TopicsStatus.loading && state.fromLocal) {
          return Center(
            child: SizedBox(
              height: 24,
              width: 24,
              child: Loader(),
            ),
          );
          // Do not show error for remote fetch
        } else if (state.status == TopicsStatus.error && state.fromLocal) {
          return Center(
            child: Text(
              'Failed to load topics',
              style: context.theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          );
        } else {
          // Filter only featured topics
          final featuredTopics =
              state.topics.where((topic) => topic.featured).toList();

          if (featuredTopics.isEmpty) {
            return Center(
              child: Text(
                'No featured topics found',
                style: context.theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            );
          }

          return GridView.builder(
            key: const PageStorageKey('topics_grid'),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              // Using tile bottom padding instead of mainAxisSpacing
              // mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              mainAxisExtent: max(
                MediaQuery.of(context).size.height * 0.14,
                80,
              ),
            ),
            itemCount: featuredTopics.length,
            itemBuilder: (context, index) {
              return TopicTile(
                topic: featuredTopics[index],
                onTap: onTap,
              );
            },
          );
        }
      },
    );
  }
}

class TopicTile extends StatelessWidget {
  final Topic topic;
  final Function(Topic, Color) onTap;

  const TopicTile({
    super.key,
    required this.topic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color tileColor =
        HSLColor.fromColor(topic.dynamicColor ?? Colors.grey.withAlpha(110))
            .withLightness(
              context.theme.brightness == Brightness.dark ? 0.75 : 0.3,
            )
            .toColor();
    final imageProvider =
        context.read<TopicsBloc>().state.imageProviders[topic.code];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          onTap(topic, tileColor);
        },
        splashFactory: NoSplash.splashFactory,
        borderRadius: BorderRadius.circular(UIConstants.tileItemBorderRadius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(UIConstants.tileItemBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 2,
                spreadRadius: 0.5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              // If image is available, show it
              if (topic.imageUrl != null)
                Positioned.fill(
                  child: _TileImage(
                    imageProvider: imageProvider,
                    tileColor: tileColor,
                    topic: topic,
                  ),
                ),
              // If no image, show a solid color
              if (topic.imageUrl == null)
                Positioned.fill(
                  child: _buildColoredTile(tileColor),
                ),
              // Tile color gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      UIConstants.tileItemBorderRadius,
                    ),
                    gradient: LinearGradient(
                      stops: const [0, 0.7],
                      colors: [
                        context.theme.brightness == Brightness.dark
                            ? HSLColor.fromColor(tileColor)
                                .withLightness(0.2)
                                .withSaturation(0.4)
                                .withAlpha(0.3)
                                .toColor()
                            : HSLColor.fromColor(tileColor)
                                .withLightness(0.9)
                                .withAlpha(0.4)
                                .toColor(),
                        tileColor.withAlpha(50),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTileText(context, tileColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AutoSizeText _buildTileText(BuildContext context, Color tileColor) {
    return AutoSizeText(
      topic.name,
      style: context.theme.textTheme.titleMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        height: 1.2,
        shadows: [
          Shadow(
            color: context.theme.brightness == Brightness.dark
                ? Colors.black.withAlpha(140)
                : HSLColor.fromColor(tileColor)
                    .withLightness(0.95)
                    .withAlpha(0.853)
                    .toColor(),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        color: HSLColor.fromColor(tileColor)
            .withLightness(
              context.theme.brightness == Brightness.dark ? 0.95 : 0.1,
            )
            .withAlpha(1)
            .toColor(),
      ),
      wrapWords: false,
      textAlign: TextAlign.start,
      maxLines: 2,
      minFontSize: 16,
      maxFontSize: 18,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _TileImage extends StatelessWidget {
  const _TileImage({
    required this.imageProvider,
    required this.tileColor,
    required this.topic,
  });

  final ImageProvider<Object>? imageProvider;
  final Color tileColor;
  final Topic topic;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(UIConstants.tileItemBorderRadius),
      child: imageProvider != null
          ? Image(
              image: imageProvider!,
              fit: BoxFit.cover,
              color: context.theme.brightness == Brightness.dark
                  ? Colors.black.withAlpha(80)
                  : Colors.white.withAlpha(65),
              colorBlendMode: context.theme.brightness == Brightness.dark
                  ? BlendMode.darken
                  : BlendMode.lighten,
              errorBuilder: (context, error, stackTrace) =>
                  _buildColoredTile(tileColor),
            )
          : CachedNetworkImage(
              imageUrl: topic.imageUrl!,
              cacheKey: topic.imageUrl!,
              fit: BoxFit.cover,
              color: context.theme.brightness == Brightness.dark
                  ? Colors.black.withAlpha(80)
                  : Colors.white.withAlpha(65),
              colorBlendMode: context.theme.brightness == Brightness.dark
                  ? BlendMode.darken
                  : BlendMode.lighten,
              fadeInDuration: Duration(milliseconds: 100),
              memCacheWidth: (MediaQuery.of(context).size.width).toInt(),
              placeholder: (context, url) => _buildColoredTile(tileColor),
              errorListener: (e) {
                if (kDebugMode) {
                  print('Error loading image: $e');
                }
              },
              errorWidget: (context, url, error) =>
                  _buildColoredTile(tileColor),
            ),
    );
  }
}

Widget _buildColoredTile(Color tileColor) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(
        UIConstants.tileItemBorderRadius,
      ),
      color: tileColor,
    ),
  );
}
