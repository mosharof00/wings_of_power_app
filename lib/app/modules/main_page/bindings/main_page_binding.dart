import 'package:wings_of_power_app/app/data/repositories/achievement_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/auth_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/home_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/profile_repository.dart';
import 'package:wings_of_power_app/app/data/services/student_profile_store.dart';
import 'package:wings_of_power_app/app/data/repositories/story_repository.dart';
import 'package:wings_of_power_app/app/modules/achievements/controllers/achievements_controller.dart';
import 'package:wings_of_power_app/app/modules/game/bindings/game_binding.dart';
import 'package:wings_of_power_app/app/modules/game/controllers/game_mode_select_controller.dart';
import 'package:wings_of_power_app/app/modules/home/controllers/home_controller.dart';
import 'package:wings_of_power_app/app/modules/profile/controllers/profile_controller.dart';
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
    GameBinding().dependencies();
    Get.lazyPut<MainPageController>(
      () => MainPageController(
        onGameTabOpened: () =>
            Get.find<GameModeSelectController>().reloadStudentStats(),
        onBadgesTabOpened: () => Get.find<AchievementsController>().fetchBadges(),
        onStudentTabOpened: () => Get.find<StudentProfileStore>().refresh(),
      ),
    );
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<IHomeRepository>()),
    );
    Get.lazyPut<StoriesController>(
      () => StoriesController(Get.find<IStoryRepository>()),
    );
    Get.lazyPut<AchievementsController>(
      () => AchievementsController(Get.find<IAchievementRepository>()),
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        Get.find<IProfileRepository>(),
        Get.find<IAuthRepository>(),
        Get.find<StudentProfileStore>(),
      ),
    );
  }
}
