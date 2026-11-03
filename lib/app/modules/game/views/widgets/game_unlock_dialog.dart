import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/models/game_eligibility.dart';

class GameUnlockDialog extends StatelessWidget {
  const GameUnlockDialog({
    super.key,
    required this.eligibility,
    required this.onContinueReading,
    this.onClose,
  });

  final GameEligibilityModel eligibility;
  final VoidCallback onContinueReading;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final rules = eligibility.rules;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Main Card
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 48.h),
            padding: EdgeInsets.fromLTRB(24.w, 64.h, 24.w, 28.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6EB),
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: const Color(0xFFFFDFC8),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Unlock the Game Show!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                SizedBox(height: 16.h),
                // Dynamic Rules Copy
                Text(
                  'Complete ${rules.requiredStories} stories or ${rules.requiredChapters} chapters and score ${rules.minQuizPercent}% or higher to unlock the basketball game show',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                SizedBox(height: 28.h),
                // Continue Reading Button
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: onContinueReading,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE86726),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26.r),
                      ),
                    ),
                    child: Text(
                      'Continue Reading',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Close button at top-right of the card
          Positioned(
            top: 60.h,
            right: 16.w,
            child: GestureDetector(
              onTap: onClose ?? () => Get.back(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: const Color(0xFFF5B895),
                  size: 26.sp,
                ),
              ),
            ),
          ),
          // Top Overlapping Circular Lock Badge
          Positioned(
            top: 0,
            child: Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFDFC8),
                  width: 3.w,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x24F26C29),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 58.w,
                  height: 58.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF26C29),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 32.sp,
                      ),
                      Positioned(
                        top: 28.h,
                        child: Container(
                          width: 4.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF26C29),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

