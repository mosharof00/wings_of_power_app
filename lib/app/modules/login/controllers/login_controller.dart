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

  final remember = false.obs;
  final obscure = true.obs;
  final submitting = false.obs;
  final error = ''.obs;

  void toggleRemember() => remember.value = !remember.value;

  void toggleObscure() => obscure.value = !obscure.value;

  /// Drawn on Login-1.png. No student reset screen exists, so this stays here.
  void forgotPassword() {}

  void openJoin() => Get.toNamed(Routes.JOIN_CLASS);

  void clearError() {
    if (error.value.isNotEmpty) error.value = '';
  }

  /// Temporary frame capture. Remove before the task is done.
  @override
  void onReady() {
    super.onReady();
    _captureFrames();
  }

  Future<void> _captureFrames() async {
    debugPrint('CAPTURE frame=empty route=${Get.currentRoute}');
    await Future<void>.delayed(const Duration(seconds: 3));
    forgotPassword();
    debugPrint('CAPTURE forgot_stays=${Get.currentRoute}');
    username.text = 'sam';
    password.text = 'secret1';
    remember.value = true;
    obscure.value = false;
    debugPrint('CAPTURE frame=filled');
    await Future<void>.delayed(const Duration(seconds: 3));
    obscure.value = true;
    username.text = 'nope';
    password.text = 'bad';
    final wrong = submit();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    debugPrint('CAPTURE frame=loading submitting=${submitting.value}');
    await wrong;
    debugPrint(
      'CAPTURE frame=error message=${error.value} route=${Get.currentRoute}',
    );
    await Future<void>.delayed(const Duration(seconds: 3));
    openJoin();
    debugPrint('CAPTURE frame=join route=${Get.currentRoute}');
    await Future<void>.delayed(const Duration(seconds: 2));
    Get.back();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    username.text = 'sam';
    password.text = 'secret1';
    remember.value = true;
    await submit();
    debugPrint(
      'CAPTURE frame=home route=${Get.currentRoute} persist=${remember.value}',
    );
    await Future<void>.delayed(const Duration(seconds: 2));
    try {
      await _auth.loginStudent(
        username: 'pending',
        password: 'x',
        remember: false,
      );
    } on ApiException catch (e) {
      debugPrint('CAPTURE pending_status=${e.statusCode} ${e.message}');
      Get.offAllNamed(Routes.PENDING_APPROVAL);
    }
    debugPrint('CAPTURE frame=pending route=${Get.currentRoute}');
  }

  Future<void> submit() async {
    final name = username.text.trim();
    final pass = password.text;
    if (name.isEmpty || pass.isEmpty || submitting.value) return;
    error.value = '';
    submitting.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 900));
    try {
      final session = await _auth.loginStudent(
        username: name,
        password: pass,
        remember: remember.value,
      );
      if (session.status == 'PENDING') {
        Get.offAllNamed(Routes.PENDING_APPROVAL);
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
        Get.offAllNamed(Routes.PENDING_APPROVAL);
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
    username.dispose();
    password.dispose();
    super.onClose();
  }
}
