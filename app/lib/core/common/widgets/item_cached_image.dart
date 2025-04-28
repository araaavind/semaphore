import 'dart:math';

import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/feed/domain/entities/item.dart';
import 'package:app/features/feed/utils/extract_best_image_url.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ItemCachedImage extends StatefulWidget {
  final Item item;
  final double? width;
  final double? height;
  const ItemCachedImage({
    required this.item,
    this.width,
    this.height,
    super.key,
  });

  @override
  State<ItemCachedImage> createState() => _ItemCachedImageState();
}

class _ItemCachedImageState extends State<ItemCachedImage> {
  String _url = '';
  bool _isGif = false;
  bool _isLoading = true;
  final _dio = Dio();

  @override
  void initState() {
    super.initState();
    _loadImageURL();
  }

  Future<void> _loadImageURL() async {
    final imageUrls = await getItemImageUrls(widget.item);
    String workingUrl = '';
    int attempts = 0;
    for (var url in imageUrls) {
      if (attempts >= 2) {
        break;
      }
      if (url.contains('.svg')) {
        continue;
      }
      try {
        await _dio.head(url);
        workingUrl = url;
        break;
      } catch (e) {
        if (kDebugMode) print('Error loading image: $e');
      }
      attempts++;
    }
    if (mounted) {
      setState(() {
        _url = workingUrl;
        _isGif = workingUrl.endsWith('.gif');
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildShimmerLoader(context);
    }
    if (_url == '') {
      return _buildNoImageWidget(context, widget.height, widget.width);
    }
    if (_isGif) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 3,
              spreadRadius: 0,
              offset: const Offset(0.5, 0.5),
            ),
          ],
          borderRadius: BorderRadius.circular(UIConstants.imageBorderRadius),
        ),
        foregroundDecoration: BoxDecoration(
          color: context.theme.colorScheme.primaryContainer.withAlpha(100),
          borderRadius: BorderRadius.circular(UIConstants.imageBorderRadius),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: Image.network(_url).image,
          ),
        ),
        child: _buildNoImageWidget(context, widget.height, widget.width),
      );
    }
    return CachedNetworkImage(
      memCacheWidth: widget.width != null
          ? (widget.width!.toInt() * View.of(context).devicePixelRatio.ceil())
          : null,
      memCacheHeight: widget.height != null
          ? (widget.height!.toInt() * View.of(context).devicePixelRatio.ceil())
          : null,
      maxWidthDiskCache: widget.width != null
          ? (widget.width!.toInt() * View.of(context).devicePixelRatio.ceil())
          : null,
      maxHeightDiskCache: widget.height != null
          ? (widget.height!.toInt() * View.of(context).devicePixelRatio.ceil())
          : null,
      width: widget.width,
      height: widget.height,
      imageUrl: _url,
      imageBuilder: (context, imageProvider) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 3,
              spreadRadius: 0,
              offset: const Offset(0.5, 0.5),
            ),
          ],
          borderRadius: BorderRadius.circular(UIConstants.imageBorderRadius),
        ),
        foregroundDecoration: BoxDecoration(
          color: context.theme.colorScheme.primaryContainer.withAlpha(100),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: imageProvider,
          ),
          borderRadius: BorderRadius.circular(UIConstants.imageBorderRadius),
        ),
        child: _buildNoImageWidget(context, widget.height, widget.width),
      ),
      placeholder: (context, _) => _buildShimmerLoader(context),
      errorWidget: (context, url, error) {
        return _buildNoImageWidget(context, widget.height, widget.width);
      },
      errorListener: (e) {
        if (kDebugMode) {
          print('Error listener for widget ${widget.item.title}: $e');
        }
      },
    );
  }

  Shimmer _buildShimmerLoader(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.theme.colorScheme.primary.withAlpha(30),
      highlightColor: context.theme.colorScheme.primary.withAlpha(65),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UIConstants.imageBorderRadius),
          color: Colors.white,
        ),
      ),
    );
  }
}

Widget _buildNoImageWidget(
  BuildContext context,
  double? height,
  double? width,
) {
  final random = Random();
  final hue = random.nextDouble() * 360;
  final color = HSLColor.fromAHSL(
    0.4, // Alpha
    hue, // Random Hue
    0.5, // Low Saturation (40%)
    context.theme.brightness == Brightness.dark
        ? 0.8
        : 0.2, // High Lightness (80%)
  ).toColor();

  return Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(UIConstants.imageBorderRadius),
      color: color,
    ),
    child: Center(
      child: Text(
        'SMPHR',
        style: context.theme.textTheme.bodySmall!.copyWith(
          color: context.theme.colorScheme.surface.withAlpha(180),
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}
