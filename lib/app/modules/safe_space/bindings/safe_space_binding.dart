import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/repositories/safe_space_repository.dart';
import '../controllers/safe_space_controller.dart';

class SafeSpaceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SafeSpaceController>(
      () => SafeSpaceController(Get.find<ISafeSpaceRepository>()),
      fenix: true,
    );
  }
}
