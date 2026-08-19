import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/color_tokens.dart';

/// Helper widget yang secara otomatis menangani:
/// 1. Network Image (http:// atau https://)
/// 2. Local File Image (Path dari ImagePicker / kamera / galeri)
/// 3. Fallback placeholder jika image kosong/error
class SmartImage extends StatelessWidget {
  final String? pathOrUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;

  const SmartImage({
    super.key,
    required this.pathOrUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = placeholder ??
        Container(
          width: width,
          height: height,
          color: TrimeColors.surfaceAlt,
          child: Center(
            child: Icon(
              Icons.storefront_outlined,
              size: 32,
              color: TrimeColors.primaryNavy.withValues(alpha: 0.4),
            ),
          ),
        );

    if (pathOrUrl == null || pathOrUrl!.trim().isEmpty) {
      return fallback;
    }

    final trimmed = pathOrUrl!.trim();

    // Clean file:// prefix jika ada
    String cleanPath = trimmed;
    if (cleanPath.startsWith('file://')) {
      cleanPath = cleanPath.substring(7);
    }

    // 1. Cek jika URL HTTP/HTTPS
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, error, stack) => fallback,
      );
    }

    // 2. Cek jika Local File
    try {
      final file = File(cleanPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, error, stack) => fallback,
        );
      }
    } catch (_) {}

    return fallback;
  }
}

/// Helper CircleAvatar yang secara otomatis menangani:
/// 1. Network Image (http:// / https://)
/// 2. Local FileImage
/// 3. Fallback Icon jika belum ada foto
class SmartAvatar extends StatelessWidget {
  final String? pathOrUrl;
  final double radius;
  final IconData fallbackIcon;

  const SmartAvatar({
    super.key,
    required this.pathOrUrl,
    this.radius = 36,
    this.fallbackIcon = Icons.person,
  });

  ImageProvider? get _imageProvider {
    if (pathOrUrl == null || pathOrUrl!.trim().isEmpty) return null;
    final trimmed = pathOrUrl!.trim();
    String cleanPath = trimmed;
    if (cleanPath.startsWith('file://')) {
      cleanPath = cleanPath.substring(7);
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return NetworkImage(trimmed);
    }
    try {
      final file = File(cleanPath);
      if (file.existsSync()) {
        return FileImage(file);
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = _imageProvider;
    return CircleAvatar(
      radius: radius,
      backgroundColor: TrimeColors.surfaceAlt,
      backgroundImage: provider,
      child: provider == null
          ? Icon(
              fallbackIcon,
              size: radius * 1.1,
              color: TrimeColors.primaryNavy.withValues(alpha: 0.5),
            )
          : null,
    );
  }
}
