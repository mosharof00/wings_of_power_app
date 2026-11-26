import 'package:flutter/material.dart';

class StudentAvatarImage extends StatelessWidget {
  const StudentAvatarImage({super.key, required this.avatarUrl});

  static const defaultAsset = 'assets/images/avatar_01.png';

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final path = avatarUrl?.trim() ?? '';
    final uri = Uri.tryParse(path);
    final fallback = Image.asset(defaultAsset, fit: BoxFit.cover);

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    if (uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.hasAuthority) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    return fallback;
  }
}
