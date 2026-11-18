import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/app_scaffold.dart';
import 'package:wings_of_power_app/app/global/widgets/custom_icon_button.dart';
import 'package:wings_of_power_app/app/global/widgets/global_button.dart';
import 'package:wings_of_power_app/app/routes/app_pages.dart';
import '../controllers/heroes_controller.dart';
import 'widgets/hero_card.dart';
import 'widgets/hero_flow_screen.dart';

/// Matches `Power Hero.png` (student.power_hero).
/// Reached from profile “My Power Hero”.
class PowerHeroView extends GetView<HeroesController> {
  const PowerHeroView({super.key});

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
                        'My Power Hero',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColor.secondary,
                        ),
                      ),
                    ),
                    SizedBox(width: 40.w), // Balance back button
                  ],
                ),
              ),

              // Unlocked heroes grid
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final unlocked = controller.heroes
                      .where((h) => h.isUnlocked)
                      .toList();

                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.h,
                      crossAxisSpacing: 16.w,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: unlocked.length,
                    itemBuilder: (context, index) {
                      final hero = unlocked[index];
                      final isSelected =
                          hero.id == controller.activeHero.value?.id;
                      return HeroCard(
                        hero: hero,
                        isSelected: isSelected,
                        showDetails: true,
                        onTap: () => controller.onRosterHeroTapped(hero),
                      );
                    },
                  );
                }),
              ),

              // Bottom button: See All Power Heroes
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                child: GlobalButton(
                  onTap: () => Get.toNamed(Routes.HERO_ROSTER),
                  text: 'See All Power Heroes',
                  height: 48.h,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
