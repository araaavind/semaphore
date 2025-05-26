import 'dart:math';

import 'package:app/core/common/widgets/loader.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/features/feed/domain/entities/topic.dart';
import 'package:app/features/feed/presentation/bloc/topics/topics_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  void initState() {
    super.initState();
    context.read<TopicsBloc>().add(ListTopicsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Explore',
          style: context.theme.textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: UIConstants.pagePadding),
        child: TopicsGrid(),
      ),
    );
  }
}

class TopicsGrid extends StatelessWidget {
  const TopicsGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicsBloc, TopicsState>(
      builder: (context, state) {
        if (state is TopicsLoading) {
          return Center(
            child: SizedBox(
              height: 24,
              width: 24,
              child: Loader(),
            ),
          );
        } else if (state is TopicsError) {
          return Center(
            child: Text(
              'Failed to load topics',
              style: context.theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          );
        } else if (state is TopicsLoaded) {
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: featuredTopics.length,
            itemBuilder: (context, index) {
              return TopicTile(topic: featuredTopics[index]);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class TopicTile extends StatelessWidget {
  final Topic topic;

  const TopicTile({
    super.key,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    final Color tileColor = _getTopicColor(context, topic.color);

    return InkWell(
      onTap: () {
        // Handle topic tap
      },
      splashFactory: NoSplash.splashFactory,
      borderRadius: BorderRadius.circular(UIConstants.tileItemBorderRadius),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UIConstants.tileItemBorderRadius),
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
            if (topic.imageUrl != null)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(UIConstants.tileItemBorderRadius),
                  child: CachedNetworkImage(
                    color: context.theme.brightness == Brightness.dark
                        ? Colors.black.withAlpha(80)
                        : Colors.white.withAlpha(80),
                    colorBlendMode: context.theme.brightness == Brightness.dark
                        ? BlendMode.darken
                        : BlendMode.lighten,
                    imageUrl: topic.imageUrl!,
                    cacheKey: topic.code,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              UIConstants.tileItemBorderRadius),
                          color: tileColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (topic.imageUrl == null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(UIConstants.tileItemBorderRadius),
                    color: tileColor,
                  ),
                ),
              ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(UIConstants.tileItemBorderRadius),
                  gradient: LinearGradient(
                    stops: const [0.2, 1],
                    colors: [
                      context.theme.brightness == Brightness.dark
                          ? Colors.black.withAlpha(50)
                          : Colors.white.withAlpha(50),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter,
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
                  AutoSizeText(
                    topic.name,
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: context.theme.brightness == Brightness.dark
                          ? context.theme.colorScheme.onSurface.withAlpha(230)
                          : context.theme.colorScheme.onSurface.withAlpha(210),
                    ),
                    wrapWords: false,
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    minFontSize: 15,
                    maxFontSize: 17,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _getTopicColor(BuildContext context, String? color) {
  if (color == null || color.isEmpty) {
    final random = Random();
    final hue = random.nextDouble() * 360;
    return HSLColor.fromAHSL(
      0.4, // Alpha
      hue, // Random Hue
      1.0, // Medium Saturation (80%)
      context.theme.brightness == Brightness.dark
          ? 0.75
          : 0.3, // High Lightness (80%)
    ).toColor();
  }
  return Color(int.parse(color.replaceAll('#', '0xFF')));
}
