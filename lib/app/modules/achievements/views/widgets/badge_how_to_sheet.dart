import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/achievement_models.dart';
import 'package:wings_of_power_app/app/global/widgets/global_button.dart';

void showBadgeHowToSheet(BuildContext context, BadgeModel badge) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => BadgeHowToSheet(badge: badge),
  );
}

class BadgeHowToSheet extends StatelessWidget {
  const BadgeHowToSheet({super.key, required this.badge});

  final BadgeModel badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 48.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColor.subtitle.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 18.h),

          // Badge Artwork
          Image.asset(
            badge.assetPath,
            width: 105.w,
            height: 105.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 14.h),

          // "Locked" pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9F2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 15.sp,
                  color: const Color(0xFF6B5A8A),
                ),
                SizedBox(width: 5.w),
                Text(
                  'Locked',
                  style: GoogleFonts.nunito(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6B5A8A),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Title
          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColor.secondary,
            ),
          ),
          SizedBox(height: 6.h),

          // Subtitle
          Text(
            badge.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.subtitle,
            ),
          ),
          SizedBox(height: 16.h),

          // "How to earn" container
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: const Color(0xFFCDEAF6),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.nunito(
                  fontSize: 13.sp,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: AppColor.secondary,
                ),
                children: [
                  const TextSpan(
                    text: 'How to earn: ',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text: badge.howToEarn.replaceFirst('How to earn: ', ''),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 22.h),

          // CTA: Ok, Got It!
          GlobalButton(
            text: 'Ok, Got It!',
            onTap: () => Navigator.of(context).pop(),
            height: 50.h,
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
          ),
        ],
      ),
    );
  }
}
