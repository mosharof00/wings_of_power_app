import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';

/// Full-body hero with the blue floor oval that was removed from the PNGs.
class HeroPortrait extends StatelessWidget {
  const HeroPortrait({
    super.key,
    required this.assetPath,
    this.heroTag,
  });

  final String assetPath;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      assetPath,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.person_rounded,
        size: 96,
        color: AppColor.subtitle,
      ),
    );
    if (heroTag != null) {
      image = Hero(tag: heroTag!, child: image);
    }

    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Container(
              width: 176.w,
              height: 26.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: const Color(0xFFA2D0E5).withValues(alpha: 0.9),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7EB6D6).withValues(alpha: 0.45),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(child: image),
        ],
      ),
    );
  }
}
