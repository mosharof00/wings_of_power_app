import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';

import '../../../global/widgets/global_button.dart';
import '../../../global/widgets/step_progress.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  static const _titleColor = Color(0xFF104F6F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: SizedBox(
                height: 36.h,
                child: Obx(() {
                  if (controller.page.value >= 2) return const SizedBox.shrink();
                  return Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: controller.finish,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.nunito(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.secondary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: [
                  for (final page in controller.pages)
                    _OnboardingPage(page: page),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Obx(
              () => StepProgress(count: 3, index: controller.page.value),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
              child: Obx(
                () => GlobalButton(
                  text: controller.page.value == 2 ? 'Get Started' : 'Next',
                  onTap: controller.next,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.page});

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Image.asset(
            page.image,
            width: double.infinity,
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          page.title,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            color: OnboardingView._titleColor,
            height: 1.15,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          page.body,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColor.subtitle,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
