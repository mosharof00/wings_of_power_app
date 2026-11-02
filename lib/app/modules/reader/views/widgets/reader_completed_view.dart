import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/core/theme/app_radius.dart';
import 'package:wings_of_power_app/app/global/widgets/global_button.dart';
import 'package:wings_of_power_app/app/modules/reader/controllers/reader_controller.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

class ReaderCompletedView extends StatelessWidget {
  const ReaderCompletedView({
    super.key,
    required this.controller,
  });

  final ReaderController controller;

  @override
  Widget build(BuildContext context) {
    final chapterNumber = controller.chapter.value?.chapterNumber ?? 1;

    return Scaffold(
      backgroundColor: AppColor.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            Assets.backgrounds.bgAuthSky.path,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                Image.asset(
                  Assets.characters.heroApproval.path,
                  height: 280.h,
                  fit: BoxFit.contain,
                ),
                Transform.translate(
                  offset: Offset(0, -12.h),
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 24.w),
                    padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
                    decoration: BoxDecoration(
                      color: AppColor.cream,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'You Finished Chapter $chapterNumber!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColor.secondary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Your wings grew a little stronger today',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColor.subtitle,
                          ),
                        ),
                        SizedBox(height: 22.h),
                        GlobalButton(
                          text: 'Take Quiz Now!',
                          onTap: controller.onTakeQuiz,
                        ),
                        SizedBox(height: 12.h),
                        GestureDetector(
                          onTap: controller.onBackToHome,
                          child: Container(
                            width: double.infinity,
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.button.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Back to Home',
                                style: GoogleFonts.nunito(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
