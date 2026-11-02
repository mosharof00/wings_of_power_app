import 'package:wings_of_power_app/app/data/repositories/achievement_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/home_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/story_repository.dart';
import 'package:wings_of_power_app/app/modules/achievements/controllers/achievements_controller.dart';
import 'package:wings_of_power_app/app/modules/home/controllers/home_controller.dart';
import 'package:wings_of_power_app/app/modules/stories/controllers/stories_controller.dart';
import 'package:get/get.dart';

import '../controllers/main_page_controller.dart';

/// Route-scoped: these controllers live while the main page is in the stack
/// and are disposed when it leaves (e.g. on logout). Use
/// `HelperUtils.backToMain()` instead of `Get.offAllNamed(Routes.MAIN_PAGE)`
/// to return here without recreating them.
class MainPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainPageController>(() => MainPageController());
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<IHomeRepository>()),
    );
    Get.lazyPut<StoriesController>(
      () => StoriesController(Get.find<IStoryRepository>()),
    );
    Get.lazyPut<AchievementsController>(
      () => AchievementsController(Get.find<IAchievementRepository>()),
    );
  }
}
