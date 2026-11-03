import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GamePeerLeftBanner extends StatelessWidget {
  const GamePeerLeftBanner({
    super.key,
    required this.name,
    this.avatarUrl,
    this.onDismiss,
  });

  final String name;
  final String? avatarUrl;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFFFDFC8), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x29000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar circle with warm golden-yellow border
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFB300), width: 2),
              ),
              child: ClipOval(
                child: _buildAvatarImage(),
              ),
            ),
            SizedBox(width: 14.w),

            // Text detail
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Player Left!',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$name left this game. You can continue this game to earn points and shoots.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4B5563),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      if (avatarUrl!.startsWith('http://') || avatarUrl!.startsWith('https://')) {
        return Image.network(
          avatarUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _defaultAvatar(),
        );
      }
      return Image.asset(
        avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _defaultAvatar(),
      );
    }
    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    return Image.asset(
      'assets/images/avatar_01.png',
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const Icon(
        Icons.person,
        size: 26,
        color: Color(0xFF9CA3AF),
      ),
    );
  }
}
