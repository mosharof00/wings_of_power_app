import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GameWaitingOverlay extends StatelessWidget {
  const GameWaitingOverlay({
    super.key,
    this.title = 'Waiting for your classmates',
    this.subtitle = 'One of your classmates is still thinking',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: const Color(0x99000000),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4D6),
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated glowing center icon
                  Container(
                    width: 84.w,
                    height: 84.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE68A),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.sports_basketball,
                        color: const Color(0xFFE86726),
                        size: 44.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 22.h),

                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Subtitle
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Circular Progress Indicator
                  SizedBox(
                    width: 32.w,
                    height: 32.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(Color(0xFFE86726)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

