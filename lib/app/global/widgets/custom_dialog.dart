import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/core/theme/app_radius.dart';

import 'app_svg_icon.dart';
import 'app_text.dart';

/// Cream confirm sheet. Title, body, and the actions passed as [bottomWidget].
class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    this.iconPath,
    required this.title,
    required this.subtitle,
    this.bottomWidget,
    this.iconWidth,
    this.iconHeight,
  });

  final String? iconPath;
  final String title;
  final String subtitle;
  final Widget? bottomWidget;
  final double? iconWidth;
  final double? iconHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.cream,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColor.primaryDisable,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 16.h),
            if (iconPath != null) ...[
              AppSvgIcon(
                iconPath!,
                width: iconWidth,
                height: iconHeight,
              ),
              SizedBox(height: 12.h),
            ],
            AppText(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColor.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            AppText(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColor.subtitle,
              ),
            ),
            if (bottomWidget != null) ...[
              SizedBox(height: 20.h),
              bottomWidget!,
            ],
          ],
        ),
      ),
    );
  }
}
