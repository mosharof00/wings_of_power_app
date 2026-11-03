import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/network/api_exception.dart';
import 'package:wings_of_power_app/app/core/utils/helper_utils.dart';
import 'package:wings_of_power_app/app/data/mocks/profile.dart';
import 'package:wings_of_power_app/app/data/models/user_models/student_profile_model.dart';
import 'package:wings_of_power_app/app/data/models/user_models/student_settings_model.dart';
import 'package:wings_of_power_app/app/data/repositories/auth_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/profile_repository.dart';
import 'package:wings_of_power_app/app/routes/app_pages.dart';

import '../views/widgets/how_app_works_sheet.dart';
import '../views/widgets/profile_logout_sheet.dart';

class ProfileController extends GetxController {
  final IProfileRepository _profileRepo;
  final IAuthRepository _authRepo;

  ProfileController(this._profileRepo, this._authRepo);

  final profile = Rxn<StudentProfileModel>();
  final settings = Rx<StudentSettingsModel>(const StudentSettingsModel());

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isChangingPassword = false.obs;
  final passwordError = ''.obs;

  final selectedAvatar = 'assets/images/avatar_01.png'.obs;
  final nameController = TextEditingController();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final obscureCurrent = true.obs;
  final obscureNew = true.obs;
  final obscureConfirm = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    nameController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchProfile(),
        fetchSettings(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProfile() async {
    try {
      final res = await _profileRepo.getProfile();
      profile.value = res;
      selectedAvatar.value = res.avatarUrl;
      nameController.text = res.nickname;
    } catch (_) {
      // Keep existing or default
    }
  }

  Future<void> fetchSettings() async {
    try {
      final res = await _profileRepo.getSettings();
      settings.value = res;
    } catch (_) {
      // Keep existing
    }
  }

  // ── Settings Toggles ──────────────────────────────────────────

  Future<void> toggleReadToMe(bool value) async {
    settings.value = settings.value.copyWith(readToMe: value);
    await _profileRepo.updateSettings(settings.value);
  }

  Future<void> toggleSound(bool value) async {
    settings.value = settings.value.copyWith(soundEffect: value);
    await _profileRepo.updateSettings(settings.value);
  }

  Future<void> toggleStories(bool value) async {
    settings.value = settings.value.copyWith(notifyStories: value);
    await _profileRepo.updateSettings(settings.value);
  }

  Future<void> toggleBadges(bool value) async {
    settings.value = settings.value.copyWith(notifyBadges: value);
    await _profileRepo.updateSettings(settings.value);
  }

  Future<void> toggleGameShow(bool value) async {
    settings.value = settings.value.copyWith(notifyGameShow: value);
    await _profileRepo.updateSettings(settings.value);
  }

  Future<void> toggleSafeSpace(bool value) async {
    settings.value = settings.value.copyWith(notifySafeSpace: value);
    await _profileRepo.updateSettings(settings.value);
  }

  // ── Edit Profile ─────────────────────────────────────────────

  void initEditForm() {
    selectedAvatar.value = profile.value?.avatarUrl ?? ProfileMock.presetAvatars.first;
    nameController.text = profile.value?.nickname ?? 'Sarah';
  }

  void selectAvatar(String path) {
    selectedAvatar.value = path;
  }

  Future<void> saveProfile() async {
    isSaving.value = true;
    try {
      final updated = await _profileRepo.updateProfile(
        nickname: nameController.text.trim(),
        avatarUrl: selectedAvatar.value,
      );
      profile.value = updated;
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isSaving.value = false;
    }
  }

  // ── Change Password ──────────────────────────────────────────

  void clearPasswordForm() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    passwordError.value = '';
    obscureCurrent.value = true;
    obscureNew.value = true;
    obscureConfirm.value = true;
  }

  Future<void> submitChangePassword() async {
    final current = currentPasswordController.text;
    final next = newPasswordController.text;
    final confirm = confirmPasswordController.text;

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      passwordError.value = 'Please fill in all fields.';
      return;
    }

    if (next != confirm) {
      passwordError.value = 'New passwords do not match.';
      return;
    }

    if (next.length < 6) {
      passwordError.value = 'Password must be at least 6 characters.';
      return;
    }

    isChangingPassword.value = true;
    passwordError.value = '';
    try {
      await _authRepo.changePassword(current: current, next: next);
      clearPasswordForm();
      Get.back();
      Get.snackbar(
        'Success',
        'Password updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      // 400 or other API errors stay on form
      passwordError.value = e.message;
    } catch (e) {
      passwordError.value = e.toString();
    } finally {
      isChangingPassword.value = false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      await _authRepo.logout();
    } catch (_) {
      // Ignore logout API failures, proceed to clear session
    } finally {
      await HelperUtils.clearUser();
      await HelperUtils.deleteMainControllers();
      Get.offAllNamed(Routes.WELCOME);
    }
  }

  // ── Navigation & Sheets ───────────────────────────────────────

  void openSettings() {
    Get.toNamed(Routes.SETTINGS);
  }

  void openEditProfile() {
    initEditForm();
    Get.toNamed(Routes.EDIT_PROFILE);
  }

  void openChangePassword() {
    clearPasswordForm();
    Get.toNamed(Routes.CHANGE_PASSWORD);
  }

  void openLogoutSheet() {
    Get.bottomSheet(
      const ProfileLogoutSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
    );
  }

  void openHowAppWorksSheet() {
    Get.bottomSheet(
      const HowAppWorksSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
    );
  }

  void openHeroes() => Get.toNamed(Routes.POWER_HERO);
  void openReadingProgress() => Get.toNamed(Routes.READING_PROGRESS);
  void openBadges() => Get.toNamed(Routes.BADGES);
  void openPositivePoints() => Get.toNamed(Routes.POSITIVE_POINTS);
  void openLeaderboard() => Get.toNamed(Routes.LEADERBOARD);
  void openSafeSpaceReports() => Get.toNamed(Routes.SAFE_SPACE_REPORTS);
  void openSafeSpaceIntro() => Get.toNamed(Routes.SAFE_SPACE);

  /// Notifications row tap does nothing (D14)
  void onNotificationTap() {}
}
