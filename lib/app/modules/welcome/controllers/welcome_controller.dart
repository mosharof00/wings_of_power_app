import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

enum WelcomeEmphasis { login, join }

class WelcomeController extends GetxController {
  final emphasis = WelcomeEmphasis.login.obs;

  @override
  void onInit() {
    if (Get.arguments == WelcomeEmphasis.join) {
      emphasis.value = WelcomeEmphasis.join;
    }
    super.onInit();
  }

  void openLogin() => Get.toNamed(Routes.LOGIN);

  void openJoin() => Get.toNamed(Routes.JOIN_CLASS);
}
