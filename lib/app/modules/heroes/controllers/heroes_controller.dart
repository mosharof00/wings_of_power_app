import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/mocks/heroes.dart';
import 'package:wings_of_power_app/app/data/models/hero_models.dart';
import 'package:wings_of_power_app/app/data/repositories/auth_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/hero_repository.dart';
import 'package:wings_of_power_app/app/routes/app_pages.dart';
import '../views/widgets/hero_confirm_dialog.dart';
import '../views/widgets/hero_detail_sheet.dart';
import '../views/widgets/hero_locked_dialog.dart';

enum HeroSignupStep { grid, detail, ready }

class HeroesController extends GetxController {
  HeroesController(this._heroRepo, this._authRepo);

  final IHeroRepository _heroRepo;
  final IAuthRepository _authRepo;

  final heroes = <HeroModel>[].obs;
  final activeHero = Rxn<HeroModel>();
  final previewHero = Rxn<HeroModel>();
  final signupStep = HeroSignupStep.grid.obs;

  final isLoading = false.obs;
  final isSelecting = false.obs;
  final mockActive = false.obs;
  final allUnlocked = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadHeroes();
  }

  Future<void> loadHeroes() async {
    isLoading.value = true;
    try {
      final list = await _heroRepo.getHeroes();
      heroes.assignAll(list);
      final current = list.firstWhereOrNull((h) => h.isSelected) ??
          list.firstWhereOrNull((h) => h.code == 'MICHELE') ??
          list.firstOrNull;
      activeHero.value = current;
      previewHero.value = current;
    } finally {
      isLoading.value = false;
    }
  }

  void onSignupHeroTapped(HeroModel hero) {
    if (!hero.isUnlocked) {
      showLockedDialog(hero);
      return;
    }
    previewHero.value = hero;
    signupStep.value = HeroSignupStep.detail;
  }

  void backToSignupGrid() {
    signupStep.value = HeroSignupStep.grid;
  }

  void openSignupConfirm(HeroModel hero) {
    Get.dialog(
      HeroConfirmDialog(
        hero: hero,
        onConfirm: () {
          Get.back();
          confirmFirstHero(hero);
        },
        onCancel: () => Get.back(),
      ),
    );
  }

  Future<void> confirmFirstHero(HeroModel hero) async {
    isSelecting.value = true;
    try {
      final selected = await _heroRepo.selectHero(hero.id);
      activeHero.value = selected;
      previewHero.value = selected;
      final updated = heroes.map((h) {
        return h.copyWith(isSelected: h.id == selected.id);
      }).toList();
      heroes.assignAll(updated);
      signupStep.value = HeroSignupStep.ready;
    } finally {
      isSelecting.value = false;
    }
  }

  /// After a successful select, call `GET /api/auth/me`.
  /// `PENDING` -> account verification (`T-APP-007`).
  /// `ACTIVE` -> home.
  /// With mocks, returns `PENDING` so the dead end can be checked,
  /// and [mockActive] toggle in controller can return `ACTIVE` so home opens.
  Future<void> proceedFromReady() async {
    if (mockActive.value) {
      Get.offAllNamed(Routes.MAIN_PAGE);
      return;
    }
    try {
      final me = await _authRepo.getMe();
      final status = me.data?.status ?? 'PENDING';
      if (status == 'ACTIVE') {
        Get.offAllNamed(Routes.MAIN_PAGE);
      } else {
        Get.offAllNamed(Routes.PENDING_APPROVAL);
      }
    } catch (_) {
      Get.offAllNamed(Routes.PENDING_APPROVAL);
    }
  }

  void onRosterHeroTapped(HeroModel hero, BuildContext context) {
    if (!hero.isUnlocked) {
      showLockedDialog(hero);
      return;
    }
    previewHero.value = hero;
    showRosterHeroDetail(hero, context);
  }

  Future<void> selectRosterHero(HeroModel hero) async {
    if (!hero.isUnlocked) return;
    isSelecting.value = true;
    try {
      final selected = await _heroRepo.selectHero(hero.id);
      activeHero.value = selected;
      final updated = heroes.map((h) {
        return h.copyWith(isSelected: h.id == selected.id);
      }).toList();
      heroes.assignAll(updated);
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
    } finally {
      isSelecting.value = false;
    }
  }

  void exploreStories() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    Get.offAllNamed(Routes.MAIN_PAGE);
  }

  void toggleAllUnlocked() {
    allUnlocked.value = !allUnlocked.value;
    HeroesMock.allUnlockedOverride = allUnlocked.value;
    loadHeroes();
  }

  void showLockedDialog(HeroModel hero) {
    Get.dialog(
      HeroLockedDialog(
        onExploreStories: exploreStories,
        onClose: () => Get.back(),
      ),
    );
  }

  void showRosterHeroDetail(HeroModel hero, BuildContext context) {
    Get.bottomSheet(
      Container(
        height: 680.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        clipBehavior: Clip.antiAlias,
        child: HeroDetailContent(
          hero: hero,
          isSignup: false,
          onBack: () => Get.back(),
          onChoose: () => selectRosterHero(hero),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
