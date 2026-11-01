import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/hero_models.dart';
import 'package:wings_of_power_app/app/global/widgets/global_button.dart';

class HeroDetailContent extends StatelessWidget {
  const HeroDetailContent({
    super.key,
    required this.hero,
    required this.onChoose,
    this.isSignup = false,
    this.onBack,
  });

  final HeroModel hero;
  final VoidCallback onChoose;
  final bool isSignup;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final locked = !hero.isUnlocked;
    final isCurrent = hero.isSelected;

    String buttonText;
    bool isButtonDisabled = false;

    if (isSignup) {
      buttonText = 'Choose ${hero.displayName}';
    } else if (locked) {
      buttonText = 'Complete 2 Stories to unlock one hero';
      isButtonDisabled = true;
    } else if (isCurrent) {
      buttonText = 'Current Hero';
      isButtonDisabled = true;
    } else {
      buttonText = 'Choose ${hero.displayName}';
    }

    return Column(
      children: [
        // Top section with hero portrait
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFB7E7FE),
                      Color(0xFFE2F4FD),
                    ],
                  ),
                ),
              ),
              if (onBack != null)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8.h,
                  left: 16.w,
                  child: Semantics(
                    button: true,
                    label: 'Back',
                    child: GestureDetector(
                      onTap: onBack,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: AppColor.white.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18.w,
                          color: AppColor.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 50.h, 24.w, 12.h),
                  child: Hero(
                    tag: 'hero-${hero.id}',
                    child: Image.asset(
                      hero.assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 96,
                          color: AppColor.subtitle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom section with details card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  hero.fullNameRole,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColor.secondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Bullied for: ${hero.bulliedFor}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColor.subtitle,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  hero.quote.startsWith('"')
                      ? hero.quote
                      : '"${hero.quote}"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 14.sp,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: AppColor.secondary,
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4D6),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFFFFE299),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    hero.powerSummary,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColor.secondary,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                GlobalButton(
                  onTap: isButtonDisabled ? () {} : onChoose,
                  isDisabled: isButtonDisabled,
                  text: buttonText,
                  height: 48.h,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
