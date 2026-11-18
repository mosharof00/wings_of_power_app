import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/helper_utils.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  LoginController(this._auth);

  final IAuthRepository _auth;

  final username = TextEditingController();
  final password = TextEditingController();

  final remember = true.obs;
  final obscure = true.obs;
  final submitting = false.obs;
  final isFormFilled = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    username.addListener(_updateFormFilled);
    password.addListener(_updateFormFilled);
  }

  void _updateFormFilled() {
    isFormFilled.value =
        username.text.trim().isNotEmpty && password.text.isNotEmpty;
  }

  void toggleRemember() => remember.value = !remember.value;

  void toggleObscure() => obscure.value = !obscure.value;

  void forgotPassword() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Need a new password?'),
        content: const Text(
          'That’s okay, little hero!\n\n'
          'Ask your teacher or school helper. '
          'They can give you a new password so you can sign in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void openJoin() => Get.toNamed(Routes.JOIN_CLASS);

  void clearError() {
    if (error.value.isNotEmpty) error.value = '';
  }

  Future<void> submit() async {
    final name = username.text.trim();
    final pass = password.text;
    if (name.isEmpty || pass.isEmpty || submitting.value) return;
    error.value = '';
    submitting.value = true;
    try {
      final session = await _auth.loginStudent(
        username: name,
        password: pass,
        remember: remember.value,
      );
      if (session.status == 'PENDING') {
        Get.toNamed(Routes.PENDING_APPROVAL);
        return;
      }
      await HelperUtils.setUser(
        userId: session.userId,
        token: session.accessToken,
        role: 'STUDENT',
        persist: remember.value,
      );
      Get.offAllNamed(Routes.MAIN_PAGE);
    } on ApiException catch (e) {
      if (e.statusCode == 422 && e.message.toUpperCase().contains('PENDING')) {
        Get.toNamed(Routes.PENDING_APPROVAL);
        return;
      }
      error.value = e.statusCode == 401
          ? 'That username or password doesn’t look right.'
          : e.message;
    } finally {
      submitting.value = false;
    }
  }

  @override
  void onClose() {
    username.removeListener(_updateFormFilled);
    password.removeListener(_updateFormFilled);
    username.dispose();
    password.dispose();
    super.onClose();
  }
}
