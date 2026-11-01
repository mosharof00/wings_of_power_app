import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/hero_models.dart';

/// Matches `Character showing.png` (student.hero_ready).
///
/// Note: The design PNG has no button/CTA. The flow stops on this frame until
/// design adds a control. Tapping the card or invoking [onProceed] advances
/// to `GET /api/auth/me` -> PENDING (account verification) or ACTIVE (home).
class HeroReadyView extends StatelessWidget {
  const HeroReadyView({
    super.key,
    required this.hero,
    required this.onProceed,
  });

  final HeroModel hero;
  final VoidCallback onProceed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onProceed,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB7E7FE),
              Color(0xFFF3FAFF),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Hero(
                  tag: 'hero-${hero.id}',
                  child: Image.asset(
                    hero.assetPath,
                    height: 320.h,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(
                      Icons.person_rounded,
                      size: 96,
                      color: AppColor.subtitle,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  '${hero.displayName} is ready!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColor.secondary,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  hero.quote.startsWith('"')
                      ? hero.quote
                      : '"${hero.quote}"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 15.sp,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: AppColor.subtitle,
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
