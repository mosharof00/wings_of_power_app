import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/repositories/home_repository.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<IHomeRepository>()),
    );
  }
}
