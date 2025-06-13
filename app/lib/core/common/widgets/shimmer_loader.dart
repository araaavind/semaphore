import 'dart:math';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/icons/mingcute.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'shimmer_placeholders.dart';

enum ShimmerLoaderType {
  text,
  magazine,
  card,
  lines,
  smallmag,
  feedmag,
}

class ShimmerLoader extends StatelessWidget {
  final int pageSize;
  final ShimmerLoaderType type;
  const ShimmerLoader({
    required this.pageSize,
    this.type = ShimmerLoaderType.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.theme.colorScheme.primary.withAlpha(20),
      highlightColor: context.theme.colorScheme.primary.withAlpha(45),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            for (int i = 0; i < pageSize; i++) _buildShimmerItem(context),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerItem(BuildContext context) {
    switch (type) {
      case ShimmerLoaderType.text:
        return _buildTextShimmer();
      case ShimmerLoaderType.magazine:
        return _buildMagazineShimmer(context);
      case ShimmerLoaderType.smallmag:
        return _buildSmallMagazineShimmer(context);
      case ShimmerLoaderType.feedmag:
        return _buildFeedMagazineShimmer(context);
      case ShimmerLoaderType.card:
        return _buildCardShimmer(context);
      case ShimmerLoaderType.lines:
        return _buildLinesShimmer(context);
    }
  }

  Widget _buildTextShimmer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18.0),
        const TitlePlaceholder(lineType: ContentLineType.twoLines),
        const SizedBox(height: 12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 12.0,
              width: 150.0,
              color: Colors.white,
            ),
            _buildActionButtonsRound()
          ],
        ),
      ],
    );
  }

  Widget _buildMagazineShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 105.0,
                height: 90.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4.0),
                    Container(
                      height: 16.0,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      height: 14.0,
                      width: 150.0,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 14.0),
                    Container(
                      width: double.infinity,
                      height: 8.0,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 8.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 12.0,
                width: 150.0,
                color: Colors.white,
              ),
              _buildActionButtonsRound()
            ],
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Wrap _buildActionButtonIcons() {
    return Wrap(
      spacing: 14.0,
      children: [
        Icon(
          Icons.favorite,
          size: 20.0,
          color: Colors.white,
        ),
        Icon(
          MingCute.bookmark_fill,
          size: 20.0,
          color: Colors.white,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Icon(
            MingCute.share_2_fill,
            size: 20.0,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonsRound() {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Wrap(
        spacing: 14.0,
        children: [
          for (int i = 0; i < 3; i++)
            Container(
              width: 22.0,
              height: 22.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSmallMagazineShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90.0,
            height: 60.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4.0),
                Container(
                  height: 12.0,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 8.0),
                Container(
                  height: 10.0,
                  width: 150.0,
                  color: Colors.white,
                ),
                const SizedBox(height: 14.0),
                Container(
                  width: 80,
                  height: 8.0,
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 8.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedMagazineShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 18.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8.0),
                Container(
                  height: 14.0,
                  width: Random().nextDouble() * 150 + 120,
                  color: Colors.white,
                ),
                const SizedBox(height: 14.0),
                Container(
                  width: double.infinity,
                  height: 6.0,
                  color: Colors.white,
                ),
                const SizedBox(height: 4.0),
                Container(
                  width: Random().nextDouble() * 150 + 40,
                  height: 6.0,
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 8.0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18.0),
          Container(
            width: 24.0,
            height: 24.0,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitlePlaceholder(lineType: ContentLineType.twoLines),
          const SizedBox(height: 10.0),
          Container(
            height: 180.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 12.0,
                width: 150.0,
                color: Colors.white,
              ),
              _buildActionButtonsRound(),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLinesShimmer(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10.0),
        Container(
          width: double.infinity,
          height: 18.0,
          color: Colors.white,
        ),
        const SizedBox(height: 28.0),
      ],
    );
  }
}
