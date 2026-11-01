import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/hero_models.dart';
import 'package:wings_of_power_app/app/global/widgets/global_button.dart';

class HeroConfirmDialog extends StatelessWidget {
  const HeroConfirmDialog({
    super.key,
    required this.hero,
    required this.onConfirm,
    required this.onCancel,
  });

  final HeroModel hero;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

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
        padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose ${hero.displayName} as your\nfirst character?',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColor.secondary,
                height: 1.3,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "You'll unlock more by\nfinishing stories.",
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
              onTap: onConfirm,
              text: 'Yes, Choose ${hero.displayName}',
              height: 48.h,
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
            ),
            SizedBox(height: 8.h),
            CupertinoButton(
              onPressed: onCancel,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'Go Back',
                style: GoogleFonts.nunito(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.subtitle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
