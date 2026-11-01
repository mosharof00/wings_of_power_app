import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import '../controllers/heroes_controller.dart';
import 'widgets/hero_card.dart';
import 'widgets/hero_detail_sheet.dart';
import 'widgets/hero_ready_view.dart';

class CharacterChooseView extends GetView<HeroesController> {
  const CharacterChooseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Obx(() {
        switch (controller.signupStep.value) {
          case HeroSignupStep.detail:
            final hero = controller.previewHero.value ??
                controller.activeHero.value ??
                controller.heroes.first;
            return HeroDetailContent(
              hero: hero,
              isSignup: true,
              onBack: controller.backToSignupGrid,
              onChoose: () => controller.openSignupConfirm(hero),
            );

          case HeroSignupStep.ready:
            final hero = controller.activeHero.value ??
                controller.previewHero.value ??
                controller.heroes.first;
            return HeroReadyView(
              hero: hero,
              onProceed: controller.proceedFromReady,
            );

          case HeroSignupStep.grid:
            return const _CharacterChooseGrid();
        }
      }),
    );
  }
}

class _CharacterChooseGrid extends GetView<HeroesController> {
  const _CharacterChooseGrid();

  @override
  Widget build(BuildContext context) {
    return Container(
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
            // Top bar with back button and step label "2/2"
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 20.w, 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Text(
                    '2/2',
                    style: GoogleFonts.nunito(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColor.secondary,
                    ),
                  ),
                ],
              ),
            ),

            // Header titles
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  Text(
                    'Choose your hero',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColor.secondary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Every hero has a unique power. Which one\nfeels like you?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.subtitle,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // 2-column grid of characters
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
                    final isSelected = hero.id == controller.activeHero.value?.id;
                    return HeroCard(
                      hero: hero,
                      isSelected: isSelected,
                      showDetails: false,
                      onTap: () => controller.onSignupHeroTapped(hero),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
