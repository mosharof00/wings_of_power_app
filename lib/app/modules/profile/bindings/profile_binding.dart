import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/repositories/auth_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/profile_repository.dart';
import 'package:wings_of_power_app/app/data/services/student_profile_store.dart';

import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        Get.find<IProfileRepository>(),
        Get.find<IAuthRepository>(),
        Get.find<StudentProfileStore>(),
      ),
    );
  }
}
