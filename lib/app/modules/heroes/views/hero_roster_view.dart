import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/app_scaffold.dart';
import 'package:wings_of_power_app/app/global/widgets/custom_icon_button.dart';

import '../controllers/heroes_controller.dart';
import 'widgets/hero_card.dart';
import 'widgets/hero_flow_screen.dart';

/// Matches `Character.png` / `All Character unlock.png` (student.hero_roster).
/// Reached from profile “See All Power Heroes”.
class HeroRosterView extends GetView<HeroesController> {
  const HeroRosterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.signupStep.value != HeroSignupStep.grid) {
        return const HeroFlowScreen();
      }
      return AppScaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: Row(
                  children: [
                    CustomIconButton(
                      onPressed: () => Get.back(),
                      size: 40.w,
                    ),
                    Expanded(
                      child: Text(
                        'Choose Your Hero',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColor.secondary,
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Toggle Unlocked',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: controller.toggleAllUnlocked,
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: AppColor.white.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: Obx(
                            () => Icon(
                              controller.allUnlocked.value
                                  ? Icons.lock_open_rounded
                                  : Icons.lock_outline_rounded,
                              size: 18.w,
                              color: AppColor.secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14.h,
                          crossAxisSpacing: 14.w,
                          childAspectRatio: 0.92,
                        ),
                        itemCount: controller.heroes.length,
                        itemBuilder: (context, index) {
                          final hero = controller.heroes[index];
                          final isSelected =
                              hero.id == controller.activeHero.value?.id;
                          return HeroCard(
                            hero: hero,
                            isSelected: isSelected,
                            showDetails: true,
                            onTap: () => controller.onRosterHeroTapped(hero),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
