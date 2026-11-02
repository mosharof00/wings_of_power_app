import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/achievement_models.dart';
import 'package:wings_of_power_app/app/global/widgets/global_button.dart';
import 'package:wings_of_power_app/app/routes/app_pages.dart';

void showBadgeNotificationDialog(
  BuildContext context, {
  required BadgeModel badge,
  VoidCallback? onAwesomeTap,
}) {
  showDialog<void>(
    context: context,
    builder: (ctx) => _BadgeNotificationDialog(
      badge: badge,
      onAwesomeTap: onAwesomeTap,
    ),
  );
}

void showBadgeCelebrationDialog(
  BuildContext context, {
  BadgeModel? badge,
  VoidCallback? onViewBadgeTap,
}) {
  showDialog<void>(
    context: context,
    builder: (ctx) => _BadgeCelebrationDialog(
      badge: badge,
      onViewBadgeTap: onViewBadgeTap,
    ),
  );
}

class _BadgeNotificationDialog extends StatelessWidget {
  const _BadgeNotificationDialog({
    required this.badge,
    this.onAwesomeTap,
  });

  final BadgeModel badge;
  final VoidCallback? onAwesomeTap;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: AppColor.cream,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              badge.assetPath,
              width: 120.w,
              height: 120.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16.h),
            Text(
              '${badge.name}!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: AppColor.secondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              badge.earnedDescription ??
                  "You've completed an activity and\nearned this achievement!",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.subtitle,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            GlobalButton(
              text: 'Awesome!',
              onTap: () {
                Navigator.of(context).pop();
                onAwesomeTap?.call();
              },
              height: 48.h,
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeCelebrationDialog extends StatelessWidget {
  const _BadgeCelebrationDialog({
    this.badge,
    this.onViewBadgeTap,
  });

  final BadgeModel? badge;
  final VoidCallback? onViewBadgeTap;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: AppColor.cream,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              badge?.assetPath ?? 'assets/badges/badge_story_explorer.png',
              width: 120.w,
              height: 120.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16.h),
            Text(
              'Badge Unlocked!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: AppColor.secondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Amazing work! You've earned a new badge",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.subtitle,
              ),
            ),
            SizedBox(height: 24.h),
            GlobalButton(
              text: 'View Badge',
              onTap: () {
                Navigator.of(context).pop();
                if (onViewBadgeTap != null) {
                  onViewBadgeTap!();
                } else if (Get.currentRoute != Routes.MAIN_PAGE &&
                    Get.currentRoute != Routes.BADGES) {
                  Get.toNamed(Routes.BADGES);
                }
              },
              height: 48.h,
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
            ),
          ],
        ),
      ),
    );
  }
}
