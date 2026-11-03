import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/network/api_client.dart';
import 'package:wings_of_power_app/app/core/services/secure_storage_service.dart';
import 'package:wings_of_power_app/app/data/models/game_match.dart';
import 'package:wings_of_power_app/app/data/models/hero_models.dart';
import 'package:wings_of_power_app/app/data/models/how_to_play.dart';
import 'package:wings_of_power_app/app/data/repositories/game_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/igame_repository.dart';
import 'package:wings_of_power_app/app/data/services/game_socket_service.dart';
import 'package:wings_of_power_app/app/modules/home/controllers/home_controller.dart';
import '../views/game_match_hold_view.dart';
import '../views/widgets/game_change_avatar_dialog.dart';
import '../views/widgets/game_choose_hero_dialog.dart';
import '../views/widgets/game_fixture_prompt_dialog.dart';
import '../views/widgets/game_how_to_play_sheet.dart';

class GameModeSelectController extends GetxController {
  GameModeSelectController([
    IGameRepository? repository,
    GameSocketService? socketService,
  ])  : _repository = repository ??
            (Get.isRegistered<IGameRepository>()
                ? Get.find<IGameRepository>()
                : GameRepository(Get.find<ApiClient>())),
        _socketService = socketService ??
            (Get.isRegistered<GameSocketService>()
                ? Get.find<GameSocketService>()
                : GameSocketService());

  final IGameRepository _repository;
  final GameSocketService _socketService;

  /// true = Single Player selected, false = Multi Player selected
  final isSinglePlayer = true.obs;

  final coins = 245.obs;
  final xp = 2.obs;
  final avatarUrl = RxnString();
  final nickname = 'Alex'.obs;
  final userId = RxnString();

  final selectedHero = Rxn<HeroModel>();
  final fixtureCode = RxnString();
  final isStartingPractice = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStudentStats();
    _loadHeroes();
  }

  Future<void> reloadStudentStats() async {
    await _loadStudentStats();
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
      final homePoints = homeController.points;
      if (homePoints > 0) {
        coins.value = homePoints;
      }
      avatarUrl.value = homeController.avatarUrl ?? 'assets/images/avatar_01.png';
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
      final current = heroes.firstWhereOrNull((h) => h.isSelected) ??
          heroes.firstWhereOrNull((h) => h.isUnlocked);
      if (current != null) {
        selectedHero.value = current;
      }
    } catch (_) {}
  }

  void selectSinglePlayer() {
    isSinglePlayer.value = true;
  }

  void selectMultiPlayer() {
    isSinglePlayer.value = false;
  }

  void onSinglePlayerCardTap() {
    if (!isSinglePlayer.value) {
      selectSinglePlayer();
    } else {
      startPractice();
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
      final queueResp = await _repository.joinQueue(
        mode: 'SINGLE',
        fixtureCode: code,
      );

      // Connect socket
      await _socketService.connect();

      // Retrieve match snapshot
      GameMatchSnapshot? snapshot = _socketService.latestMatch.value;
      if (snapshot == null && queueResp.matchId != null) {
        try {
          snapshot = await _repository.getMatchSnapshot(queueResp.matchId!);
        } catch (_) {}
      }

      // Fallback single practice snapshot if needed
      snapshot ??= GameMatchSnapshot(
        matchId: queueResp.matchId ??
            'practice-${DateTime.now().millisecondsSinceEpoch}',
        mode: 'SINGLE',
        phase: 'COUNTDOWN',
        deadlineAt: DateTime.now().add(const Duration(seconds: 3)),
        serverNow: DateTime.now(),
        teams: [
          GameMatchTeam(
            id: 'team-single-1',
            label: 'Single Player',
            members: [
              GameMatchParticipant(
                id: 'part-you-1',
                userId: userId.value ?? 'student-alex',
                nickname: nickname.value,
                avatarUrl: avatarUrl.value ?? 'assets/images/avatar_01.png',
                heroId: selectedHero.value?.displayName ?? 'Faith',
                jerseyNumber: 1,
                isConnected: true,
                isBot: false,
              ),
              const GameMatchParticipant(
                id: 'part-bot-1',
                userId: null,
                nickname: 'Practice Bot',
                avatarUrl: null,
                heroId: 'Harold',
                jerseyNumber: 2,
                isConnected: true,
                isBot: true,
              ),
            ],
          ),
        ],
        you: GameMatchYou(
          participantId: 'part-you-1',
          heroId: selectedHero.value?.displayName ?? 'Faith',
          jerseyNumber: 1,
        ),
      );

      Get.to(
        () => GameMatchHoldView(
          snapshot: snapshot!,
          currentUserId: userId.value,
          currentUserNickname: nickname.value,
        ),
        routeName: '/game/match',
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
    Get.back();
  }

  @override
  void onClose() {
    _socketService.disconnect();
    super.onClose();
  }
}
