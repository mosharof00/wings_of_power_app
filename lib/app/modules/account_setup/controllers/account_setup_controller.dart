import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/helper_utils.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';

enum SetupStep { credentials, nickname, realName }

class AccountSetupController extends GetxController {
  AccountSetupController(this._auth);

  final IAuthRepository _auth;

  final step = SetupStep.credentials.obs;
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final nickname = TextEditingController();
  final realName = TextEditingController();

  final nicknameValue = ''.obs;
  final realNameValue = ''.obs;
  final submitting = false.obs;

  late final String code;
  late final String classId;

  @override
  void onInit() {
    final args = Get.arguments;
    if (args is Map) {
      code = args['code']?.toString() ?? '';
      classId = args['classId']?.toString() ?? '';
    } else {
      code = '';
      classId = '';
    }
    super.onInit();
  }

  void onNickname(String value) => nicknameValue.value = value;

  void onRealName(String value) => realNameValue.value = value;

  void continueCredentials() {
    final name = username.text.trim();
    if (name.isEmpty) return;
    if (password.text.isEmpty || password.text != confirmPassword.text) return;
    step.value = SetupStep.nickname;
  }

  void continueNickname() {
    if (nickname.text.trim().isEmpty) return;
    step.value = SetupStep.realName;
  }

  Future<void> register() async {
    final name = realName.text.trim();
    if (name.isEmpty || submitting.value) return;
    submitting.value = true;
    try {
      final result = await _auth.registerStudent(
        code: code,
        username: username.text.trim(),
        password: password.text,
        nickname: nickname.text.trim(),
        realName: name,
      );
      await HelperUtils.setUser(
        userId: result.user.data?.id ?? 'student-pending',
        token: result.accessToken,
        role: 'STUDENT',
      );
      Get.offAllNamed(
        Routes.CHARACTER_CHOOSE,
        arguments: {'code': code, 'classId': classId},
      );
    } finally {
      submitting.value = false;
    }
  }

  @override
  void onClose() {
    username.dispose();
    password.dispose();
    confirmPassword.dispose();
    nickname.dispose();
    realName.dispose();
    super.onClose();
  }
}
