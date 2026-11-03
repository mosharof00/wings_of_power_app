import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/network/api_client.dart';
import 'package:wings_of_power_app/app/data/repositories/game_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/igame_repository.dart';
import '../controllers/game_mode_select_controller.dart';

class GameBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<IGameRepository>()) {
      Get.lazyPut<IGameRepository>(
        () => GameRepository(Get.find<ApiClient>()),
        fenix: true,
      );
    }
    Get.lazyPut<GameModeSelectController>(
      () => GameModeSelectController(Get.find<IGameRepository>()),
    );
  }
}

