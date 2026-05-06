import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:io' as io;

class AppImage extends StatelessWidget {
  final String? url;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool isCircular;
  final double borderRadius;

  const AppImage({
    super.key,
    this.url,
    this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.isCircular = false,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (url != null && url!.startsWith('http')) {
      image = CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
      );
    } else if (url != null && url!.startsWith('assets/')) {
      image = Image.asset(
        url!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else if (url != null && !kIsWeb) {
      image = Image.file(
        io.File(url!),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else if (url != null &&
        (url!.startsWith('blob:') || url!.startsWith('data:'))) {
      // Support for blob/data URLs on web and mobile (from pickers)
      image = Image.network(
        url!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else if (url != null && url!.startsWith('assets/')) {
      image = Image.asset(
        url!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else if (assetPath != null ||
        (url != null &&
            !url!.startsWith('http') &&
            !url!.startsWith('blob:'))) {
      image = Image.asset(
        assetPath ?? url!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else {
      image = _buildErrorWidget();
    }

    if (isCircular) {
      return ClipOval(child: image);
    }

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: image,
      );
    }

    return image;
  }

  Widget _buildPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(width: width, height: height, color: Colors.white),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}
