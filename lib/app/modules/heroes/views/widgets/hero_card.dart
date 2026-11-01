import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/hero_models.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.hero,
    required this.onTap,
    this.isSelected = false,
    this.showDetails = false,
  });

  final HeroModel hero;
  final VoidCallback onTap;
  final bool isSelected;
  final bool showDetails;

  Color _cardColor() {
    return switch (hero.code) {
      'MICHELE' => const Color(0xFFFDF1EB),
      'FAITH' => const Color(0xFFEAF7EE),
      'MICHAEL' => const Color(0xFFF2EFFC),
      'SAMANTHA' => const Color(0xFFFDF0F3),
      'CHI_SUNG' => const Color(0xFFEBF5FE),
      'RALPH' => const Color(0xFFF4F8EB),
      'HAROLD' => const Color(0xFFEAF8F8),
      'EVELYA' => const Color(0xFFFDF7EC),
      _ => const Color(0xFFFDF1EB),
    };
  }

  @override
  Widget build(BuildContext context) {
    final locked = !hero.isUnlocked;

    return Semantics(
      button: true,
      label: '${hero.displayName}, ${hero.roleTitle}, ${locked ? 'Locked' : 'Unlocked'}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _cardColor(),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isSelected ? AppColor.primary : Colors.transparent,
              width: 2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 4.h),
                        child: Hero(
                          tag: 'hero-${hero.id}',
                          child: Image.asset(
                            hero.assetPath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.person_rounded,
                              size: 48,
                              color: AppColor.subtitle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (showDetails) ...[
                      Padding(
                        padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 10.h),
                        child: Column(
                          children: [
                            Text(
                              hero.displayName,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColor.secondary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              hero.roleTitle,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColor.subtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      SizedBox(height: 8.h),
                    ],
                  ],
                ),
                if (locked) ...[
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          color: AppColor.secondary.withValues(alpha: 0.75),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          color: AppColor.white,
                          size: 20.w,
                        ),
                      ),
                    ),
                  ),
                ],
                if (isSelected) ...[
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: const BoxDecoration(
                        color: AppColor.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: AppColor.white,
                        size: 14.w,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
