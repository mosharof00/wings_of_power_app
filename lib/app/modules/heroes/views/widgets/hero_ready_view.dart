import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/hero_models.dart';
import 'package:wings_of_power_app/app/global/widgets/app_sunburst_background.dart';

import 'hero_portrait.dart';

/// Matches the ready frame: sunburst, name, and the hero quote.
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
    final quote = hero.quote.trim();
    final quoted = quote.startsWith('"') ? quote : '"$quote"';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onProceed,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const AppSunburstBackground(centerAlignment: Alignment(0, -0.18)),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  SizedBox(
                    height: 340.h,
                    child: HeroPortrait(
                      assetPath: hero.assetPath,
                      heroTag: 'hero-${hero.id}',
                    ),
                  ),
                  SizedBox(height: 28.h),
                  Text(
                    '${hero.displayName} is ready!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColor.secondary,
                    ),
                  ),
                  if (quote.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Text(
                      quoted,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 16.sp,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: AppColor.subtitle,
                      ),
                    ),
                  ],
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
