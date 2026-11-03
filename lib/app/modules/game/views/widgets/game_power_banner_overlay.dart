import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/data/models/game_match.dart';

class GamePowerBannerOverlay extends StatelessWidget {
  const GamePowerBannerOverlay({
    super.key,
    required this.powerEffect,
    this.onDismiss,
  });

  final GamePowerEffectEvent powerEffect;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final heroInfo = HeroPowerInfo.findByPowerCode(powerEffect.powerCode) ??
        HeroPowerInfo.findByHeroIdOrCode(powerEffect.powerCode) ??
        const HeroPowerInfo(
          heroCode: 'HAROLD',
          heroName: 'Harold',
          powerCode: 'LAB',
          powerLabel: 'Lab Shot',
          description: 'Removes 2 wrong answer',
          bannerTitle: 'Smart move!',
          bannerSubtitle: 'Science to the rescue! Two options eliminated!',
          assetPath: 'assets/characters/hero_harold.png',
        );

    final isTimePower = powerEffect.powerCode.toUpperCase() == 'MELODY' ||
        powerEffect.powerCode.toUpperCase() == 'COLOR' ||
        powerEffect.extraMs != null;

    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dark Blurred Backdrop
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: const Color(0x99000000),
                ),
              ),
            ),

            // Content Column
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glow + Character Image
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Golden glow sunburst circle
                      Container(
                        width: 220.w,
                        height: 220.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0xCCFFD54F),
                              Color(0x55F59E0B),
                              Color(0x00F59E0B),
                            ],
                            stops: [0.2, 0.6, 1.0],
                          ),
                        ),
                      ),
                      // Character
                      Image.asset(
                        heroInfo.assetPath,
                        height: 190.h,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.bolt_rounded,
                          size: 100.sp,
                          color: const Color(0xFFFFD54F),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // Purple Ribbon Banner
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFA855F7),
                          Color(0xFF7C3AED),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x667C3AED),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      heroInfo.bannerTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Subtitle
                  Text(
                    heroInfo.bannerSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.35,
                      shadows: const [
                        Shadow(
                          color: Color(0x88000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  // 10s accent if extra time power
                  if (isTimePower) ...[
                    SizedBox(height: 8.h),
                    Text(
                      '10s',
                      style: TextStyle(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFBBF24),
                        shadows: const [
                          Shadow(
                            color: Color(0x66000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
