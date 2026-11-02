import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/repositories/achievement_repository.dart';

import '../controllers/achievements_controller.dart';

class AchievementsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AchievementsController>(
      () => AchievementsController(Get.find<IAchievementRepository>()),
    );
  }
}
