import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';

final CacheManager sonexaArtworkCacheManager = CacheManager(
  Config(
    'sonexaArtworkCache',
    stalePeriod: const Duration(days: 180),
    maxNrOfCacheObjects: 800,
  ),
);

/// Network image backed by CachedNetworkImageProvider so artwork remains
/// available from disk after it has been successfully loaded once.
/// Keeps Flutter Image's familiar builders and sizing options for existing UI.
Image sonexaNetworkImage(
  String url, {
  Key? key,
  double? width,
  double? height,
  Color? color,
  BlendMode? colorBlendMode,
  BoxFit? fit,
  AlignmentGeometry alignment = Alignment.center,
  ImageRepeat repeat = ImageRepeat.noRepeat,
  Rect? centerSlice,
  bool matchTextDirection = false,
  bool gaplessPlayback = false,
  FilterQuality filterQuality = FilterQuality.medium,
  ImageFrameBuilder? frameBuilder,
  ImageLoadingBuilder? loadingBuilder,
  ImageErrorWidgetBuilder? errorBuilder,
  Map<String, String>? headers,
  String? semanticLabel,
  bool excludeFromSemantics = false,
}) {
  final String imageUrl = url.trim();

  return Image(
    key: key,
    image: CachedNetworkImageProvider(
      imageUrl,
      headers: headers,
      cacheManager: sonexaArtworkCacheManager,
    ),
    width: width,
    height: height,
    color: color,
    colorBlendMode: colorBlendMode,
    fit: fit,
    alignment: alignment,
    repeat: repeat,
    centerSlice: centerSlice,
    matchTextDirection: matchTextDirection,
    gaplessPlayback: gaplessPlayback,
    filterQuality: filterQuality,
    frameBuilder: frameBuilder,
    loadingBuilder: loadingBuilder,
    errorBuilder: errorBuilder,
    semanticLabel: semanticLabel,
    excludeFromSemantics: excludeFromSemantics,
  );
}
