import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/network/api_client.dart';
import 'package:wings_of_power_app/app/core/services/local_store_service.dart';
import 'package:wings_of_power_app/app/core/utils/helper_utils.dart';
import 'package:wings_of_power_app/app/data/models/game_eligibility.dart';
import 'package:wings_of_power_app/app/core/services/secure_storage_service.dart';
import 'package:wings_of_power_app/app/data/models/hero_models.dart';
import 'package:wings_of_power_app/app/data/models/how_to_play.dart';
import 'package:wings_of_power_app/app/data/repositories/game_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/igame_repository.dart';
import 'package:wings_of_power_app/app/data/services/game_socket_service.dart';
import 'package:wings_of_power_app/app/modules/home/controllers/home_controller.dart';
import 'package:wings_of_power_app/app/modules/main_page/controllers/main_page_controller.dart';
import 'package:wings_of_power_app/app/routes/app_pages.dart';

import '../views/waiting_room_1v1_view.dart';
import '../views/waiting_room_5v5_view.dart';
import '../views/widgets/game_change_avatar_dialog.dart';
import '../views/widgets/game_choose_hero_dialog.dart';
import '../views/widgets/game_congratulations_dialog.dart';
import '../views/widgets/game_fixture_prompt_dialog.dart';
import '../views/widgets/game_how_to_play_sheet.dart';
import '../views/widgets/game_unlock_dialog.dart';

class GameModeSelectController extends GetxController {
  GameModeSelectController([
    IGameRepository? repository,
    GameSocketService? socketService,
  ]) : _repository =
           repository ??
           (Get.isRegistered<IGameRepository>()
               ? Get.find<IGameRepository>()
               : GameRepository(Get.find<ApiClient>())),
       _socketService =
           socketService ??
           (Get.isRegistered<GameSocketService>()
               ? Get.find<GameSocketService>()
               : GameSocketService());

  final IGameRepository _repository;
  final GameSocketService _socketService;

  /// true = Single Player selected, false = Multi Player selected
  final isSinglePlayer = true.obs;

  final coins = 0.obs;
  final xp = 0.obs;
  final avatarUrl = RxnString();
  final nickname = 'Alex'.obs;
  final userId = RxnString();

  final selectedHero = Rxn<HeroModel>();
  final fixtureCode = RxnString();
  final isStartingPractice = false.obs;
  final eligibility = Rxn<GameEligibilityModel>();
  final eligibilityUnavailable = false.obs;
  Future<GameEligibilityModel>? _eligibilityRequest;

  @override
  void onInit() {
    super.onInit();
    _loadStudentStats();
    _loadHeroes();
    refreshEligibility();
  }

  Future<void> reloadStudentStats() async {
    await Future.wait([_loadStudentStats(), refreshEligibility()]);
  }

  Future<void> _loadStudentStats() async {
    final uid = await SecureStorageService.instance.getUserID();
    if (uid != null) {
      userId.value = uid;
    }

    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      try {
        await homeController.fetchHome();
      } catch (_) {}
      coins.value = homeController.points;
      avatarUrl.value =
          homeController.avatarUrl ?? 'assets/images/avatar_01.png';
      final greeting = homeController.greeting;
      if (greeting.contains('Hey ')) {
        final name = greeting.replaceAll('Hey ', '').replaceAll('!', '').trim();
        if (name.isNotEmpty) {
          nickname.value = name;
        }
      }
    } else {
      avatarUrl.value = 'assets/images/avatar_01.png';
    }
  }

  Future<void> _loadHeroes() async {
    try {
      final heroes = await _repository.getHeroes();
      final current =
          heroes.firstWhereOrNull((h) => h.isSelected) ??
          heroes.firstWhereOrNull((h) => h.isUnlocked);
      if (current != null) {
        selectedHero.value = current;
      }
    } catch (_) {}
  }

  Future<void> refreshEligibility() async {
    try {
      await _requestEligibility();
    } catch (_) {
      // The lobby displays a retry action when progress is unavailable.
    }
  }

  Future<GameEligibilityModel> _requestEligibility() {
    return _eligibilityRequest ??= _loadEligibility().whenComplete(() {
      _eligibilityRequest = null;
    });
  }

  Future<GameEligibilityModel> _loadEligibility() async {
    eligibilityUnavailable.value = false;
    try {
      final result = await _repository.getEligibility();
      if (!isClosed) {
        eligibility.value = result;
        xp.value = result.progress.basketballXp;
      }
      return result;
    } catch (_) {
      if (!isClosed) eligibilityUnavailable.value = true;
      rethrow;
    }
  }

  Future<bool> _canPlay() async {
    final GameEligibilityModel access;
    try {
      access = await _requestEligibility();
    } catch (_) {
      if (!isClosed) {
        Get.snackbar(
          'Basketball',
          'Couldn’t check your game access. Please try again.',
        );
      }
      return false;
    }
    if (isClosed) return false;
    if (Get.currentRoute == Routes.MAIN_PAGE &&
        Get.isRegistered<MainPageController>() &&
        Get.find<MainPageController>().selectedIndex.value != 2) {
      return false;
    }
    if (!access.eligible) {
      await Get.dialog(
        GameUnlockDialog(
          eligibility: access,
          onContinueReading: () {
            Get.back();
            if (Get.isRegistered<MainPageController>()) {
              HelperUtils.backToMain(tab: 1);
            } else {
              Get.toNamed(Routes.STORY_LIBRARY);
            }
          },
        ),
      );
      return false;
    }

    if (HiveService.read<bool>('game_congrats_shown') == true) return true;
    HiveService.write('game_congrats_shown', true);
    final playNow = await Get.to(
      () => GameCongratulationsDialog(
        onPlayNow: () => Get.back(result: true),
        onHowToPlay: onHowToPlay,
      ),
    );
    return !isClosed && playNow == true;
  }

  void onSinglePlayerCardTap() {
    if (isStartingPractice.value) return;
    isSinglePlayer.value = true;
    start1v1Matchmaking();
  }

  void onMultiPlayerCardTap() {
    if (isStartingPractice.value) return;
    isSinglePlayer.value = false;
    start5v5Matchmaking();
  }

  Future<void> start5v5Matchmaking() async {
    if (isStartingPractice.value) return;
    isStartingPractice.value = true;

    try {
      if (!await _canPlay()) return;

      await Get.to(
        () => WaitingRoom5v5View(
          currentUserId: userId.value,
          currentUserNickname: nickname.value,
          currentUserAvatar: avatarUrl.value,
          selectedHero: selectedHero.value,
        ),
        routeName: '/game/waiting-room-5v5',
      );
    } catch (e) {
      Get.snackbar(
        'Queue Error',
        e.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isStartingPractice.value = false;
    }
  }

  Future<void> start1v1Matchmaking() async {
    if (isStartingPractice.value) return;
    isStartingPractice.value = true;

    try {
      if (!await _canPlay()) return;

      await Get.to(
        () => WaitingRoom1v1View(
          currentUserId: userId.value,
          currentUserNickname: nickname.value,
          currentUserAvatar: avatarUrl.value,
          selectedHero: selectedHero.value,
        ),
        routeName: '/game/waiting-room',
      );
    } catch (e) {
      Get.snackbar(
        'Queue Error',
        e.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isStartingPractice.value = false;
    }
  }

  void onSinglePlayerLongPress() {
    final ctx = Get.context;
    if (ctx != null) {
      GameFixturePromptDialog.show(
        context: ctx,
        initialCode: fixtureCode.value,
        onSave: (code) {
          fixtureCode.value = code;
        },
        onStartMatch: (code) {
          fixtureCode.value = code;
          startPractice(fixtureCodeOverride: code);
        },
      );
    }
  }

  Future<void> startPractice({String? fixtureCodeOverride}) async {
    if (isStartingPractice.value) return;
    isStartingPractice.value = true;
    final code = fixtureCodeOverride ?? fixtureCode.value;

    try {
      if (!await _canPlay()) return;

      await Get.to(
        () => WaitingRoom1v1View(
          currentUserId: userId.value,
          currentUserNickname: nickname.value,
          currentUserAvatar: avatarUrl.value,
          selectedHero: selectedHero.value,
          mode: 'SINGLE',
          fixtureCode: code,
        ),
        routeName: '/game/practice',
      );
    } catch (e) {
      Get.snackbar(
        'Queue Error',
        e.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isStartingPractice.value = false;
    }
  }

  void onChooseHero() {
    final ctx = Get.context;
    if (ctx != null) {
      GameChooseHeroDialog.show(
        context: ctx,
        repository: _repository,
        currentSelectedHeroId: selectedHero.value?.id,
        onHeroSelected: (hero) {
          selectedHero.value = hero;
        },
      );
    }
  }

  void onChangeAvatar() {
    final ctx = Get.context;
    if (ctx != null) {
      GameChangeAvatarDialog.show(
        context: ctx,
        initialAvatar: avatarUrl.value,
        studentName: nickname.value,
        onSave: (newAvatar) async {
          avatarUrl.value = newAvatar;
          try {
            await _repository.updateAvatar(newAvatar);
          } catch (_) {}
        },
      );
    }
  }

  Future<void> onHowToPlay() async {
    try {
      final howToPlay = await _repository.getHowToPlay();
      await GameHowToPlaySheet.show(howToPlay: howToPlay);
    } catch (_) {
      await GameHowToPlaySheet.show(
        howToPlay: HowToPlayModel(steps: HowToPlayModel.defaultSteps),
      );
    }
  }

  void onHomeTap() {
    _socketService.disconnect();
    HelperUtils.backToMain();
  }

  static void returnToLobby() {
    if (Get.isRegistered<MainPageController>()) {
      HelperUtils.backToMain(tab: 2);
      if (Get.isRegistered<GameModeSelectController>()) {
        Get.find<GameModeSelectController>().reloadStudentStats();
      }
    } else {
      Get.offAllNamed(Routes.GAME_MODE_SELECT);
    }
  }

  @override
  void onClose() {
    _socketService.disconnect();
    super.onClose();
  }
}
