import 'package:flutter/material.dart';
import 'package:wings_of_power_app/app/core/network/handle_exceptions.dart';
import 'package:wings_of_power_app/app/core/utils/helper_utils.dart';
import 'package:wings_of_power_app/app/data/repositories/auth_repository.dart';
import 'package:wings_of_power_app/app/global/widgets/global_snackbar.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final IAuthRepository _authRepository = Get.find<IAuthRepository>();

  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final rememberMe = true.obs;
  final isLoading = false.obs;

  void toggleRememberMe() => rememberMe.value = !rememberMe.value;

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(email)) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if ((value ?? '').isEmpty) return 'Password is required';
    return null;
  }

  Future<void> onLogin() async {
    if (isLoading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      isLoading.value = true;
      final response = await _authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final data = response.data;
      final token = data?.accessToken;
      final userId = data?.userId;

      if (response.success != true ||
          token == null ||
          token.isEmpty ||
          userId == null ||
          userId.isEmpty) {
        globalSnackBar(
          title: 'Login Failed',
          message: response.message ?? 'Unable to login. Please try again.',
        );
        return;
      }

      await HelperUtils.setUser(
        userId: userId,
        token: token,
        role: data?.type,
        persist: rememberMe.value,
      );

      Get.offAllNamed(Routes.MAIN_PAGE);
    } catch (e) {
      handleException(e, context: 'Login');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
