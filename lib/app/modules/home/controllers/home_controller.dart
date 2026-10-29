import 'package:wings_of_power_app/app/core/network/handle_exceptions.dart';
import 'package:wings_of_power_app/app/core/utils/helper_utils.dart';
import 'package:wings_of_power_app/app/data/models/user_models/user_model.dart';
import 'package:wings_of_power_app/app/data/repositories/auth_repository.dart';
import 'package:wings_of_power_app/app/routes/app_pages.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final IAuthRepository _authRepository = Get.find<IAuthRepository>();

  final user = Rxn<UserData>();
  final isUserLoading = false.obs;

  bool get isLoggedIn => HelperUtils.isLogin;

  String get avatarUrl => user.value?.hasAvatar == true
      ? user.value!.avatar!
      : HelperUtils.defaultProfileImage;

  @override
  void onInit() {
    super.onInit();
    if (isLoggedIn) fetchUser();
  }

  Future<void> fetchUser() async {
    if (isUserLoading.value) return;
    try {
      isUserLoading.value = true;
      final response = await _authRepository.getMe();
      if (response.success == true) user.value = response.data;
    } catch (e) {
      handleException(e, context: 'Home - Get Me');
    } finally {
      isUserLoading.value = false;
    }
  }

  void onAuthAction() {
    if (isLoggedIn) {
      HelperUtils.confirmLogout();
    } else {
      Get.toNamed(Routes.LOGIN);
    }
  }
}
