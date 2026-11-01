import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/global_button.dart';

class HeroLockedDialog extends StatelessWidget {
  const HeroLockedDialog({
    super.key,
    required this.onExploreStories,
    this.onClose,
  });

  final VoidCallback onExploreStories;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.cream,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unlock This Hero!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColor.secondary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Complete 2 stories to unlock a new\nhero! Every story brings you closer to\nyour next adventure.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColor.subtitle,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            GlobalButton(
              onTap: onExploreStories,
              text: 'Explore Stories',
              height: 48.h,
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
            ),
          ],
        ),
      ),
    );
  }
}
