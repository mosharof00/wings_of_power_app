import 'package:flutter/material.dart';

class BadgeArt extends StatelessWidget {
  const BadgeArt({super.key, required this.path, this.width, this.height});

  static const lockedPath = 'assets/badges/badge_locked.png';

  final String path;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(
      lockedPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
    final uri = Uri.tryParse(path);
    if (uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.hasAuthority) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    if (path.startsWith('assets/') && path != lockedPath) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    return fallback;
  }
}
