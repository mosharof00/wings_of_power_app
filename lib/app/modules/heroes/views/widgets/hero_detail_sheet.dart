import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/hero_models.dart';
import 'package:wings_of_power_app/app/global/widgets/custom_icon_button.dart';
import 'package:wings_of_power_app/app/global/widgets/global_button.dart';

import 'hero_portrait.dart';

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

    if (locked) {
      buttonText = 'Choose ${hero.displayName}';
      isButtonDisabled = true;
    } else if (isSignup) {
      buttonText = 'Choose ${hero.displayName}';
    } else if (isCurrent) {
      buttonText = 'Current Hero';
      isButtonDisabled = true;
    } else {
      buttonText = 'Choose ${hero.displayName}';
    }

    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 56.h, 24.w, 8.h),
                child: HeroPortrait(
                  assetPath: hero.assetPath,
                  heroTag: 'hero-${hero.id}',
                ),
              ),
              if (onBack != null)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8.h,
                  left: 16.w,
                  child: CustomIconButton(
                    onPressed: onBack,
                    size: 40.w,
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
                if (hero.quote.trim().isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Text(
                    hero.quote.trim().startsWith('"')
                        ? hero.quote.trim()
                        : '"${hero.quote.trim()}"',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 14.sp,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: AppColor.secondary,
                    ),
                  ),
                ],
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
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
                if (locked) ...[
                  SizedBox(height: 10.h),
                  Text(
                    'Complete 2 Stories to unlock one hero',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.subtitle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
