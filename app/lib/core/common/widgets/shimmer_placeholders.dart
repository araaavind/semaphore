import 'dart:math';

import 'package:flutter/material.dart';

class BannerPlaceholder extends StatelessWidget {
  const BannerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200.0,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white,
      ),
    );
  }
}

enum ContentLineType {
  oneLine,
  twoLines,
  threeLines,
}

class TitlePlaceholder extends StatelessWidget {
  final ContentLineType lineType;
  const TitlePlaceholder({
    this.lineType = ContentLineType.oneLine,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: lineType == ContentLineType.twoLines
              ? double.infinity
              : Random().nextDouble() * 150 + 250,
          height: 14.0,
          color: Colors.white,
        ),
        if (lineType == ContentLineType.twoLines) const SizedBox(height: 8.0),
        if (lineType == ContentLineType.twoLines)
          Container(
            width: Random().nextDouble() * 150 + 200,
            height: 14.0,
            color: Colors.white,
          ),
      ],
    );
  }
}

class ContentPlaceholder extends StatelessWidget {
  final ContentLineType lineType;
  final bool hasImage;

  const ContentPlaceholder({
    super.key,
    required this.lineType,
    this.hasImage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (hasImage)
          Container(
            width: 96.0,
            height: 72.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
            ),
          ),
        if (hasImage) const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 8.0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 8.0),
              ),
              if (lineType == ContentLineType.threeLines)
                Container(
                  width: double.infinity,
                  height: 8.0,
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 8.0),
                ),
              Container(
                width: Random().nextDouble() * 300 + 100,
                height: 8.0,
                color: Colors.white,
              )
            ],
          ),
        )
      ],
    );
  }
}
