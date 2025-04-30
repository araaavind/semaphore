import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'shimmer_placeholders.dart';

enum ShimmerLoaderType {
  text,
  magazine,
  card,
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
      case ShimmerLoaderType.card:
        return _buildCardShimmer(context);
    }
  }

  Widget _buildTextShimmer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18.0),
        const TitlePlaceholder(lineType: ContentLineType.twoLines),
        const SizedBox(height: 8.0),
        Container(
          width: double.infinity,
          height: 8.0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 8.0),
        ),
        const SizedBox(height: 12.0),
      ],
    );
  }

  Widget _buildMagazineShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100.0,
            height: 80.0,
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
    );
  }

  Widget _buildCardShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4.0),
          Container(
            width: double.infinity,
            height: 8.0,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8.0),
          ),
          const SizedBox(height: 6.0),
          const TitlePlaceholder(),
          const SizedBox(height: 12.0),
          Container(
            height: 180.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
