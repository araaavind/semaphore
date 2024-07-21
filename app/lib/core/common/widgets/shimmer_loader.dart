import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'shimmer_placeholders.dart';

class ShimmerLoader extends StatelessWidget {
  final int pageSize;
  const ShimmerLoader({
    required this.pageSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200.0,
      height: 100.0,
      child: Shimmer.fromColors(
        baseColor: context.theme.brightness == Brightness.dark
            ? Colors.grey.shade900
            : Colors.grey.shade300,
        highlightColor: context.theme.brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.grey.shade100,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              for (int i = 0; i < pageSize; i++)
                const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 18.0),
                    TitlePlaceholder(),
                    SizedBox(height: 8.0),
                    ContentPlaceholder(
                      hasImage: false,
                      lineType: ContentLineType.twoLines,
                    ),
                    SizedBox(height: 12.0),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
