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

  /// Navy titles from Onboarding design frames.
  static const _titleColor = Color(0xFF104F6F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: PageView.builder(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        itemCount: controller.pages.length,
        itemBuilder: (context, index) {
          return _OnboardingSlide(
            page: controller.pages[index],
            index: index,
            pageCount: controller.pages.length,
            onSkip: controller.finish,
            onNext: controller.next,
          );
        },
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.page,
    required this.index,
    required this.pageCount,
    required this.onSkip,
    required this.onNext,
  });

  final OnboardingPage page;
  final int index;
  final int pageCount;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isLast = index >= pageCount - 1;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Image.asset(
            page.image,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 4.h, 12.w, 16.h),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColor.secondary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Skip',
                      style: GoogleFonts.nunito(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.secondary,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    page.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: OnboardingView._titleColor,
                      height: 1.15,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    page.body,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: OnboardingView._titleColor.withValues(alpha: 0.85),
                      height: 1.35,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                StepProgress(count: pageCount, index: index),
                SizedBox(height: 16.h),
                GlobalButton(
                  text: isLast ? 'Get Started' : 'Next',
                  onTap: onNext,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
