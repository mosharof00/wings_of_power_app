import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/helper_utils.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  Future<void> setupApp() async {
    await Future.delayed(const Duration(seconds: 2));

    navigateToScreen();
  }

  Future<void> navigateToScreen() async {
    final isLoggedIn = await HelperUtils.checkLoginStatus()
        .timeout(const Duration(seconds: 5), onTimeout: () => false);

    final goToLogin = !isLoggedIn && AppConfig.requireLogin;
    Get.offAllNamed(goToLogin ? Routes.LOGIN : Routes.MAIN_PAGE);
  }

  @override
  void onInit() {
    setupApp();
    super.onInit();
  }
}
