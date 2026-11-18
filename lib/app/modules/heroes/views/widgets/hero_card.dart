import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/hero_models.dart';

class HeroLockBadge extends StatelessWidget {
  const HeroLockBadge({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final box = size ?? 58.w;
    return Container(
      width: box,
      height: box,
      padding: EdgeInsets.all(box * 0.2),
      decoration: BoxDecoration(
        color: AppColor.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF6D7C4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SvgPicture.asset('assets/icons/ic_lock.svg'),
    );
  }
}

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
      'FAITH' => const Color(0xFFFFF3E8),
      'MICHELE' => const Color(0xFFE7F6DC),
      'MICHAEL' => const Color(0xFFF4EAF8),
      'SAMANTHA' => const Color(0xFFF7F0E4),
      'CHI' || 'CHI_SUNG' => const Color(0xFFE5EAE4),
      'RALPH' => const Color(0xFFF3EEE6),
      'HAROLD' => const Color(0xFFE7E5EE),
      'EVELYA' => const Color(0xFFEFE8F4),
      _ => const Color(0xFFFFF3E8),
    };
  }

  @override
  Widget build(BuildContext context) {
    final locked = !hero.isUnlocked;

    return Semantics(
      button: true,
      label:
          '${hero.displayName}, ${hero.roleTitle}, ${locked ? 'Locked' : 'Unlocked'}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _cardColor(),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected ? AppColor.primary : Colors.transparent,
              width: isSelected ? 2.w : 0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
                  child: Hero(
                    tag: 'hero-${hero.id}',
                    child: Image.asset(
                      hero.assetPath,
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: AppColor.subtitle,
                      ),
                    ),
                  ),
                ),
                if (showDetails)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 8.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                  ),
                if (locked) const Center(child: HeroLockBadge()),
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
