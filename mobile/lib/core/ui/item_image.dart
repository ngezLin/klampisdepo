import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../network/dio_client.dart';

class ItemImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ItemImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final String? url = imageUrl?.trim();
    
    if (url == null || url.isEmpty) {
      return errorWidget ?? _defaultPlaceholder();
    }

    // 1. Base64 Image
    if (url.startsWith('data:image') && url.contains('base64,')) {
      try {
        final String base64Str = url.split('base64,').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => errorWidget ?? _defaultPlaceholder(),
        );
      } catch (_) {
        return errorWidget ?? _defaultPlaceholder();
      }
    }

    // 2. Network Image (Absolute or Relative)
    final String absoluteUrl = url.startsWith('http') ? url : '$apiBaseUrl$url';
    return CachedNetworkImage(
      imageUrl: absoluteUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: (_, __) => placeholder ?? Container(color: Colors.grey[100]),
      errorWidget: (_, __, ___) => errorWidget ?? _defaultPlaceholder(),
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      color: const Color(0xFFE5F7EE),
      width: width,
      height: height,
      child: const Icon(Icons.inventory_2, color: Color(0xFF00AA5B), size: 20),
    );
  }
}
