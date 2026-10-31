import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../controllers/join_class_controller.dart';

class JoinClassBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JoinClassController>(
      () => JoinClassController(Get.find<IAuthRepository>()),
    );
  }
}
