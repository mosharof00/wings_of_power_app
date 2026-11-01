import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import '../controllers/heroes_controller.dart';
import 'widgets/hero_card.dart';

/// Matches `Character.png` / `All Character unlock.png` (student.hero_roster).
/// Reached from profile “See All Power Heroes”.
class HeroRosterView extends GetView<HeroesController> {
  const HeroRosterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB7E7FE),
              Color(0xFFE2F4FD),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button, title, and unlock toggle
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: Row(
                  children: [
                    Semantics(
                      button: true,
                      label: 'Back',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Get.back(),
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
                    // Debug toggle icon for all unlocked preview
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

              // 2-column grid of all heroes
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.h,
                      crossAxisSpacing: 16.w,
                      childAspectRatio: 0.82,
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
                        onTap: () =>
                            controller.onRosterHeroTapped(hero, context),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
