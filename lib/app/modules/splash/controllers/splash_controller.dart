import 'package:get/get.dart';

import '../../../core/services/local_store_service.dart';
import '../../../core/utils/helper_utils.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  Future<void> setupApp() async {
    await Future.delayed(const Duration(seconds: 2));
    await navigateToScreen();
  }

  Future<void> navigateToScreen() async {
    final isLoggedIn = await HelperUtils.checkLoginStatus()
        .timeout(const Duration(seconds: 5), onTimeout: () => false);

    if (isLoggedIn) {
      // Account verification (PENDING) is T-APP-007. Until that screen exists,
      // a session opens the home shell.
      Get.offAllNamed(Routes.MAIN_PAGE);
      return;
    }

    final seen = await HiveService.getOnBoardShowed();
    Get.offAllNamed(seen ? Routes.WELCOME : Routes.ONBOARDING);
  }

  @override
  void onInit() {
    setupApp();
    super.onInit();
  }
}
