import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';

enum JoinStep { entry, wrong, expired, success }

class JoinClassController extends GetxController {
  JoinClassController(this._auth);

  final IAuthRepository _auth;
  final codeController = TextEditingController();
  final focusNode = FocusNode();

  final step = JoinStep.entry.obs;
  final digits = ''.obs;
  final submitting = false.obs;

  /// Kept for the register call in T-APP-007.
  String? classId;
  String? className;
  String? teacherName;

  void onCodeChanged(String raw) {
    final clipped = raw.replaceAll(RegExp(r'\D'), '');
    final next = clipped.length > 6 ? clipped.substring(0, 6) : clipped;
    if (next != codeController.text) {
      codeController.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
    digits.value = next;
    if (next.length == 6) focusNode.unfocus();
  }

  Future<void> submit() async {
    if (digits.value.length < 6 || submitting.value) return;
    submitting.value = true;
    try {
      final preview = await _auth.joinCode(code: digits.value);
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
    codeController.clear();
    digits.value = '';
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
        'code': digits.value,
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
    codeController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
