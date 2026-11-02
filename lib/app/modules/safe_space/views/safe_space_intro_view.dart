import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/custom_icon_button.dart';
import 'package:wings_of_power_app/app/global/widgets/global_button.dart';
import '../controllers/safe_space_controller.dart';

class SafeSpaceIntroView extends GetView<SafeSpaceController> {
  const SafeSpaceIntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC3EAFF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  CustomIconButton(
                    onPressed: () => Get.back(),
                    size: 40.w,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Safe Space',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.secondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 40.w), // Balance back button
                ],
              ),
            ),

            // ── Characters Illustration ──────────────────────────────
            Expanded(
              flex: 4,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Image.asset(
                    'assets/characters/safe_space_intro.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // ── Bottom Sheet Card ────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7DF),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32.r),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'You are Safe Here!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColor.secondary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'It’s ok to speak up. If something is hurting you or need help, you can tell us. Share your thoughts with caring counselors.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          color: AppColor.subtitle,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      GlobalButton(
                        onTap: controller.startNewReport,
                        text: 'Tell Us What Happened',
                        height: 52.h,
                        borderRadius: BorderRadius.circular(26.r),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD8EEFD),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Our Safe Space Guarantee',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColor.secondary,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              '1. Safe space reports never affect your points or leadership status',
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                color: AppColor.secondary,
                                height: 1.35,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '2. Reports are never public and never shared with other students.',
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                color: AppColor.secondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
