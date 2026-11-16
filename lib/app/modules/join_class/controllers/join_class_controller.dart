import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';

enum JoinStep { entry, wrong, expired, success }

class JoinClassController extends GetxController {
  JoinClassController(this._auth);

  final IAuthRepository _auth;
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  final step = JoinStep.entry.obs;
  final code = ''.obs;
  final submitting = false.obs;

  /// Kept for the register call in T-APP-007.
  String? classId;
  String? className;
  String? teacherName;

  static const codeLength = 6;

  bool get canSubmit => code.value.length == codeLength;

  void onCodeChanged(String raw) {
    final next = raw.replaceAll(RegExp(r'\D'), '');
    final clipped =
        next.length > codeLength ? next.substring(0, codeLength) : next;
    code.value = clipped;
  }

  void onCodeCompleted(String raw) {
    onCodeChanged(raw);
    if (canSubmit) {
      focusNode.unfocus();
      submit();
    }
  }

  Future<void> submit() async {
    if (!canSubmit || submitting.value) return;
    submitting.value = true;
    try {
      final preview = await _auth.joinCode(code: code.value);
      classId = preview.classId;
      className = preview.className;
      teacherName = preview.teacherName;
      step.value = JoinStep.success;
    } on ApiException catch (error) {
      step.value =
          error.statusCode == 422 ? JoinStep.expired : JoinStep.wrong;
    } finally {
      submitting.value = false;
    }
  }

  void backToCode() {
    pinController.clear();
    code.value = '';
    classId = null;
    className = null;
    teacherName = null;
    step.value = JoinStep.entry;
    focusNode.requestFocus();
  }

  void openLogin() => Get.toNamed(Routes.LOGIN);

  void continueSetup() {
    Get.toNamed(
      Routes.ACCOUNT_SETUP,
      arguments: {
        'code': code.value,
        'classId': classId,
      },
    );
  }

  @override
  void onReady() {
    focusNode.requestFocus();
    super.onReady();
  }

  @override
  void onClose() {
    pinController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
