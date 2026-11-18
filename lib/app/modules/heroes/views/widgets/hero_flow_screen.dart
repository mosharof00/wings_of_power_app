import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/global/widgets/app_scaffold.dart';

import '../../controllers/heroes_controller.dart';
import 'hero_detail_sheet.dart';
import 'hero_ready_view.dart';

/// Detail and ready steps. Grid stays on the calling screen.
class HeroFlowScreen extends GetView<HeroesController> {
  const HeroFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.signupStep.value) {
        case HeroSignupStep.detail:
          final hero = controller.previewHero.value ??
              controller.activeHero.value ??
              controller.heroes.first;
          return AppScaffold(
            body: HeroDetailContent(
              hero: hero,
              onBack: controller.backToSignupGrid,
              onChoose: () => controller.selectRosterHero(hero),
            ),
          );
        case HeroSignupStep.ready:
          final hero = controller.activeHero.value ??
              controller.previewHero.value ??
              controller.heroes.first;
          return AppScaffold(
            body: HeroReadyView(
              hero: hero,
              onProceed: controller.proceedFromReady,
            ),
          );
        case HeroSignupStep.grid:
          return const SizedBox.shrink();
      }
    });
  }
}
