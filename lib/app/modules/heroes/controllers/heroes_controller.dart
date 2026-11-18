import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/mocks/heroes.dart';
import 'package:wings_of_power_app/app/data/models/hero_models.dart';
import 'package:wings_of_power_app/app/data/repositories/auth_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/hero_repository.dart';
import 'package:wings_of_power_app/app/routes/app_pages.dart';

import '../views/widgets/hero_confirm_dialog.dart';
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
      final current = list.firstWhereOrNull((h) => h.isSelected);
      activeHero.value = current;
      previewHero.value = current;
    } finally {
      isLoading.value = false;
    }
  }

  void onSignupHeroTapped(HeroModel hero) {
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
      final shown = _keptHero(hero, selected);
      activeHero.value = shown;
      previewHero.value = shown;
      final updated = heroes.map((h) {
        return h.copyWith(isSelected: h.id == hero.id);
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

  void onRosterHeroTapped(HeroModel hero) {
    previewHero.value = hero;
    signupStep.value = HeroSignupStep.detail;
  }

  Future<void> selectRosterHero(HeroModel hero) async {
    if (!hero.isUnlocked) return;
    isSelecting.value = true;
    try {
      final selected = await _heroRepo.selectHero(hero.id);
      final shown = _keptHero(hero, selected);
      activeHero.value = shown;
      previewHero.value = shown;
      final updated = heroes.map((h) {
        return h.copyWith(isSelected: h.id == hero.id);
      }).toList();
      heroes.assignAll(updated);
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
      signupStep.value = HeroSignupStep.ready;
    } finally {
      isSelecting.value = false;
    }
  }

  /// Select response is the user payload. Keep the tapped hero's name,
  /// quote, and portrait when those fields come back empty.
  HeroModel _keptHero(HeroModel tapped, HeroModel fromApi) {
    String pick(String apiValue, String local) =>
        apiValue.trim().isNotEmpty ? apiValue : local;
    final code = pick(fromApi.code, tapped.code);
    return tapped.copyWith(
      code: code,
      displayName: pick(fromApi.displayName, tapped.displayName),
      roleTitle: pick(fromApi.roleTitle, tapped.roleTitle),
      bulliedFor: pick(fromApi.bulliedFor, tapped.bulliedFor),
      powerCode: pick(fromApi.powerCode, tapped.powerCode),
      powerLabel: pick(fromApi.powerLabel, tapped.powerLabel),
      powerDescription: pick(fromApi.powerDescription, tapped.powerDescription),
      quote: pick(fromApi.quote, tapped.quote),
      assetPath: heroAssetForCode(code),
      isSelected: true,
      isUnlocked: true,
    );
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

}
