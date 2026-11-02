import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/safe_space_models.dart';
import 'package:wings_of_power_app/app/global/widgets/global_button.dart';
import 'package:wings_of_power_app/app/routes/app_pages.dart';
import '../controllers/safe_space_controller.dart';

class SafeSpaceSubmissionSuccessView extends GetView<SafeSpaceController> {
  const SafeSpaceSubmissionSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final report = (Get.arguments is SafeSpaceReportModel)
        ? Get.arguments as SafeSpaceReportModel
        : controller.submittedReport.value;
    final publicRef = report?.publicRef ?? 'WP-1548';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Get.offAllNamed(Routes.MAIN_PAGE);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFC3EAFF),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Top Spacing ──────────────────────────────────────────
              SizedBox(height: 24.h),

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
                          'Thank You for Speaking Up!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColor.secondary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'A trusted counselor will look at this privately. You did a brave thing.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            color: AppColor.subtitle,
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // ── Report ID Pill ─────────────────────────────────
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAE6F8),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: const Color(0xFFC7BFE8),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            'Report ID: $publicRef',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4B3F72),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // ── View My Report Button ──────────────────────────
                        GlobalButton(
                          onTap: () {
                            if (report != null) {
                              controller.openReportDetail(report);
                            } else {
                              Get.toNamed(Routes.SAFE_SPACE_REPORTS);
                            }
                          },
                          text: 'View My Report',
                          height: 52.h,
                          borderRadius: BorderRadius.circular(26.r),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        SizedBox(height: 12.h),

                        // ── Back to Home Button ────────────────────────────
                        InkWell(
                          onTap: () => Get.offAllNamed(Routes.MAIN_PAGE),
                          borderRadius: BorderRadius.circular(26.r),
                          child: Container(
                            height: 52.h,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26.r),
                            ),
                            child: Text(
                              'Back to Home',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColor.primary,
                              ),
                            ),
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
      ),
    );
  }
}
