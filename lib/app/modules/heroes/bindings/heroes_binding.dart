import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/repositories/auth_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/hero_repository.dart';
import '../controllers/heroes_controller.dart';

class HeroesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HeroesController>(
      () => HeroesController(
        Get.find<IHeroRepository>(),
        Get.find<IAuthRepository>(),
      ),
    );
  }
}
