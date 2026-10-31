import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../gen/assets.gen.dart';
import '../../../core/theme/app_color.dart';

/// Dead end while `GET /api/auth/me` is `PENDING`. No action opens the home shell.
class PendingApprovalView extends StatelessWidget {
  const PendingApprovalView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColor.background,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(Assets.backgrounds.bgAuthSky.path, fit: BoxFit.cover),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    Image.asset(
                      Assets.characters.heroApproval.path,
                      height: 320.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'Approval Needed!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColor.secondary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Your account is waiting for approval\nfrom your school. Ask your teacher if\nyou need help.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColor.subtitle,
                        height: 1.4,
                      ),
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
