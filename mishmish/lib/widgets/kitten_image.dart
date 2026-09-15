import 'package:flutter/material.dart';

import '../config/theme.dart';

/// Single place for the "network image -> bundled asset -> icon"
/// fallback chain that was previously copy-pasted in every screen.
class KittenImage extends StatelessWidget {
  final String networkUrl;
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double iconSize;

  const KittenImage({
    super.key,
    required this.networkUrl,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.iconSize = 44,
  });

  @override
  Widget build(BuildContext context) {
    if (networkUrl.isEmpty) {
      return _assetFallback();
    }
    return Image.network(
      networkUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _assetFallback(),
    );
  }

  Widget _assetFallback() {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (ctx, err, st) => Container(
        width: width,
        height: height,
        color: AppColors.primarySoft,
        child: Center(
          child: Icon(Icons.pets, size: iconSize, color: AppColors.primary),
        ),
      ),
    );
  }
}
