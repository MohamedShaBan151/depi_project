import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Cached network image widget with lazy loading and fallback support
class CachedProductImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? heroTag;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  const CachedProductImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.heroTag,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  }) : super(key: key);

  Widget _buildLoadingPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        color: Colors.grey[300],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 40,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If no image URL provided, show placeholder
    if (imageUrl.isEmpty) {
      return _buildErrorWidget(context);
    }

    Widget imageWidget = ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(context),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
      ),
    );

    if (heroTag != null) {
      imageWidget = Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

/// Placeholder widget for loading states
class ImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  const ImagePlaceholder({
    Key? key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          width: width,
          height: height,
          color: Colors.grey[300],
        ),
      ),
    );
  }
}
