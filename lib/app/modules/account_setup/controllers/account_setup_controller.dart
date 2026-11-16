import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/helper_utils.dart';
import '../../../data/mocks/profile.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';

enum SetupStep { form, avatar }

enum UsernameCheckStatus { idle, checking, available, taken, invalid }

class AccountSetupController extends GetxController {
  AccountSetupController(this._auth);

  final IAuthRepository _auth;

  static final List<String> avatars = ProfileMock.presetAvatars;
  static final _usernamePattern = RegExp(r'^[a-zA-Z0-9._]{3,24}$');

  final step = SetupStep.form.obs;
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final nickname = TextEditingController();
  final realName = TextEditingController();
  final age = TextEditingController();

  final usernameError = ''.obs;
  final usernameSuccess = ''.obs;
  final usernameStatus = UsernameCheckStatus.idle.obs;
  final passwordError = ''.obs;
  final confirmError = ''.obs;
  final nicknameError = ''.obs;
  final realNameError = ''.obs;
  final ageError = ''.obs;
  final formError = ''.obs;

  final formValid = false.obs;
  final selectedAvatar = RxnString();
  final submitting = false.obs;

  late final String code;
  late final String classId;
  Timer? _usernameDebounce;
  int _usernameRequestId = 0;

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
    for (final c in [
      username,
      password,
      confirmPassword,
      nickname,
      realName,
      age,
    ]) {
      c.addListener(_revalidateForm);
    }
    super.onInit();
  }

  void _revalidateForm() {
    formValid.value = _validateForm(showErrors: false);
  }

  void onUsernameEdited(String _) {
    formError.value = '';
    usernameSuccess.value = '';
    final trimmed = username.text.trim();
    _usernameDebounce?.cancel();

    if (trimmed.isEmpty) {
      usernameError.value = '';
      usernameStatus.value = UsernameCheckStatus.idle;
      _revalidateForm();
      return;
    }

    final formatError = _usernameMessage(trimmed);
    if (formatError != null) {
      usernameError.value = formatError;
      usernameStatus.value = UsernameCheckStatus.invalid;
      _revalidateForm();
      return;
    }

    usernameError.value = '';
    usernameStatus.value = UsernameCheckStatus.checking;
    _revalidateForm();

    final requestId = ++_usernameRequestId;
    _usernameDebounce = Timer(const Duration(milliseconds: 450), () {
      unawaited(_checkUsernameAvailability(trimmed, requestId));
    });
  }

  Future<void> _checkUsernameAvailability(String value, int requestId) async {
    try {
      final available = await _auth.checkUsernameAvailable(value);
      if (requestId != _usernameRequestId || username.text.trim() != value) {
        return;
      }
      if (available) {
        usernameError.value = '';
        usernameSuccess.value = 'User name is available';
        usernameStatus.value = UsernameCheckStatus.available;
      } else {
        usernameSuccess.value = '';
        usernameError.value = 'This user name is already taken';
        usernameStatus.value = UsernameCheckStatus.taken;
      }
    } on ApiException catch (error) {
      if (requestId != _usernameRequestId) return;
      usernameSuccess.value = '';
      usernameError.value = error.message;
      usernameStatus.value = UsernameCheckStatus.invalid;
    } catch (_) {
      if (requestId != _usernameRequestId) return;
      usernameSuccess.value = '';
      usernameError.value = 'Could not check user name';
      usernameStatus.value = UsernameCheckStatus.invalid;
    }
    _revalidateForm();
  }

  void onFieldEdited() {
    formError.value = '';
    _revalidateForm();
  }

  String? _usernameMessage(String value) {
    if (value.isEmpty) return 'Enter a user name';
    if (value.length < 3) return 'Use at least 3 characters';
    if (!_usernamePattern.hasMatch(value)) {
      return 'Letters, numbers, . and _ only';
    }
    return null;
  }

  String? _ageMessage(String raw) {
    if (raw.trim().isEmpty) return 'Enter your age';
    final value = int.tryParse(raw.trim());
    if (value == null) return 'Enter a whole number';
    if (value < 4 || value > 99) return 'Age must be between 4 and 99';
    return null;
  }

  bool _validateForm({required bool showErrors}) {
    final u = username.text.trim();
    final p = password.text;
    final c = confirmPassword.text;
    final n = nickname.text.trim();
    final r = realName.text.trim();
    final a = age.text.trim();

    final uErr = _usernameMessage(u);
    final pErr = p.isEmpty
        ? 'Enter a password'
        : (p.length < 8 ? 'Use at least 8 characters' : null);
    final cErr = c.isEmpty
        ? 'Confirm your password'
        : (c != p ? 'Passwords do not match' : null);
    final nErr = n.isEmpty ? 'Enter a nick name' : null;
    final rErr = r.isEmpty ? 'Enter your real name' : null;
    final aErr = _ageMessage(a);
    final usernameOk =
        uErr == null && usernameStatus.value == UsernameCheckStatus.available;

    if (showErrors) {
      usernameError.value = uErr ??
          (usernameStatus.value == UsernameCheckStatus.taken
              ? 'This user name is already taken'
              : usernameStatus.value == UsernameCheckStatus.checking
                  ? 'Checking user name…'
                  : usernameStatus.value != UsernameCheckStatus.available &&
                          u.isNotEmpty
                      ? 'Wait for user name check'
                      : '');
      passwordError.value = pErr ?? '';
      confirmError.value = cErr ?? '';
      nicknameError.value = nErr ?? '';
      realNameError.value = rErr ?? '';
      ageError.value = aErr ?? '';
    }

    return usernameOk &&
        pErr == null &&
        cErr == null &&
        nErr == null &&
        rErr == null &&
        aErr == null;
  }

  void continueFromForm() {
    formError.value = '';
    if (!_validateForm(showErrors: true)) return;
    step.value = SetupStep.avatar;
  }

  void backToForm() {
    step.value = SetupStep.form;
  }

  void selectAvatar(String path) {
    selectedAvatar.value = path;
  }

  Future<void> submitRegistration() async {
    final avatar = selectedAvatar.value;
    if (avatar == null || submitting.value) return;
    if (!_validateForm(showErrors: true)) {
      step.value = SetupStep.form;
      return;
    }

    submitting.value = true;
    formError.value = '';
    try {
      final result = await _auth.registerStudent(
        code: code,
        username: username.text.trim(),
        password: password.text,
        confirmPassword: confirmPassword.text,
        nickname: nickname.text.trim(),
        realName: realName.text.trim(),
        age: int.parse(age.text.trim()),
        avatarUrl: avatar,
      );
      await HelperUtils.setUser(
        userId: result.user.data?.id ?? 'student-pending',
        token: result.accessToken,
        role: 'STUDENT',
      );
      Get.offAllNamed(Routes.PENDING_APPROVAL);
    } on ApiException catch (error) {
      if (error.statusCode == 409) {
        usernameError.value = 'This user name is already taken';
        usernameSuccess.value = '';
        usernameStatus.value = UsernameCheckStatus.taken;
        formError.value = 'Pick a different user name';
      } else {
        formError.value = error.message;
      }
      step.value = SetupStep.form;
    } catch (_) {
      formError.value = 'Could not create your account. Try again.';
      step.value = SetupStep.form;
    } finally {
      submitting.value = false;
    }
  }

  @override
  void onClose() {
    _usernameDebounce?.cancel();
    for (final c in [
      username,
      password,
      confirmPassword,
      nickname,
      realName,
      age,
    ]) {
      c.removeListener(_revalidateForm);
      c.dispose();
    }
    super.onClose();
  }
}
