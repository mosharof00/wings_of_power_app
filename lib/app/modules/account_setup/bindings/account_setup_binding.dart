import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../controllers/account_setup_controller.dart';

class AccountSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountSetupController>(
      () => AccountSetupController(Get.find<IAuthRepository>()),
    );
  }
}
