import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/models/game_match.dart';
import 'package:wings_of_power_app/app/data/repositories/igame_repository.dart';
import 'package:wings_of_power_app/app/data/services/game_socket_service.dart';
import 'package:wings_of_power_app/app/modules/home/controllers/home_controller.dart';
import 'package:wings_of_power_app/app/routes/app_pages.dart';
import '../controllers/game_mode_select_controller.dart';
import '../models/game_match_finished.dart';
import '../models/game_help_events.dart';
import '../views/widgets/game_leave_confirm_modal.dart';
import '../views/widgets/game_power_wings_sheet.dart';

enum GamePhase {
  hold,
  countdown,
  roundIntro,
  question,
  shootout,
  roundComplete,
  complete,
}

enum QuestionSubPhase {
  buzzerActive,
  buzzedYou,
  buzzedOther,
  answerResult,
  stealActive,
  votingActive,
  voteWaitingTeammates,
  voteWaitingOtherTeam,
  voteResult,
}

class GamePlayController extends GetxController {
  GamePlayController({
    required GameMatchSnapshot initialSnapshot,
    this.currentUserId,
    this.currentUserNickname,
    IGameRepository? repository,
    GameSocketService? socketService,
  })  : snapshot = initialSnapshot.obs,
        _repository = repository ??
            (Get.isRegistered<IGameRepository>()
                ? Get.find<IGameRepository>()
                : null),
        _socketService = socketService ??
            (Get.isRegistered<GameSocketService>()
                ? Get.find<GameSocketService>()
                : GameSocketService());

  final IGameRepository? _repository;
  final GameSocketService _socketService;
  final String? currentUserId;
  final String? currentUserNickname;

  final Rx<GameMatchSnapshot> snapshot;
  final phase = GamePhase.hold.obs;
  final questionSubPhase = QuestionSubPhase.buzzerActive.obs;

  // Countdown
  final countdownValue = 3.obs;

  // Question & Round Intro
  final currentIntro = Rxn<GameRoundIntroEvent>();
  final currentQuestion = Rxn<GameQuestionEvent>();
  final buzzWinner = Rxn<GameBuzzWinnerEvent>();
  final waiting = Rxn<GameWaitingEvent>();
  final answerResult = Rxn<GameAnswerResultEvent>();
  final stealOpen = Rxn<GameStealOpenEvent>();

  // Clock Timer
  DateTime? _activeDeadline;
  final secondsLeft = 0.obs;
  final timerString = '00:10'.obs;
  Timer? _clockTicker;

  // Selection & Scores
  final selectedOptionIndex = RxnInt();
  final isBuzzing = false.obs;
  final isSubmittingAnswer = false.obs;
  final hasPassed = false.obs;
  final serverCanPass = RxnBool();
  final buzzWinnerLine = RxnString();
  final suggestedOptionIndex = RxnInt();
  final suggestedByName = RxnString();
  final activeHelpRequest = Rxn<GameHelpRequestEvent>();
  final teamScores = <String, int>{}.obs;

  // Q2 Defense Round
  final freeTextAnswer = ''.obs;
  late final TextEditingController freeTextController;
  final isFreeTextSubmitted = false.obs;
  final isWaitingOthers = false.obs;
  final showKindnessCelebration = false.obs;
  final userKindnessCoins = 245.obs;

  // Q3 Hobby Hoops & Powers
  final hasUsedPower = false.obs;
  final activePowerEffect = Rxn<GamePowerEffectEvent>();
  final removedOptionIndices = <int>[].obs;
  final currentHint = RxnString();
  final prismWeights = <num>[].obs;
  final showingPowerBanner = Rxn<GamePowerEffectEvent>();
  Timer? _bannerTimer;

  // Shootout & Round Complete
  final shootoutStart = Rxn<GameShootoutStartEvent>();
  final shootoutResult = Rxn<GameShootoutResultEvent>();
  final roundComplete = Rxn<GameRoundCompleteEvent>();
  final hasSwiped = false.obs;
  final isSubmittingAck = false.obs;

  // Q4 Wings Final & Voting
  final voteOpen = Rxn<GameVoteOpenEvent>();
  final voteUpdate = Rxn<GameVoteUpdateEvent>();
  final voteResult = Rxn<GameVoteResultEvent>();
  final selectedVoteOptionIndex = RxnInt();
  final isVoteSubmitted = false.obs;
  final showVoteResultSheet = false.obs;
  final isVoteResultRevealed = false.obs;
  final votingTeamLabel = RxnString();

  // Match Finished & Championship Results
  final matchFinished = Rxn<GameMatchFinishedEvent>();

  // Peer Left Banner & Reconnect Grace
  final peerLeftBanner = Rxn<GamePeerLeftEvent>();
  Timer? _peerLeftTimer;
  Timer? _mockGraceTimer;

  // Subscriptions
  final List<StreamSubscription> _subscriptions = [];

  String get youParticipantId {
    if (currentUserId != null && currentUserId!.isNotEmpty) {
      final mem = snapshot.value.allParticipants
          .firstWhereOrNull((p) => p.userId == currentUserId && !p.isBot);
      if (mem?.id != null && mem!.id!.isNotEmpty) {
        return mem.id!;
      }
    }
    final youFromSnap = snapshot.value.you?.participantId;
    if (youFromSnap != null && youFromSnap.isNotEmpty) return youFromSnap;
    final mem = snapshot.value.allParticipants
        .firstWhereOrNull((p) => p.userId == currentUserId && !p.isBot);
    return mem?.id ?? 'part-you-1';
  }

  bool get canPass {
    if (hasPassed.value) return false;
    if (questionSubPhase.value != QuestionSubPhase.buzzedYou) return false;

    final rType = currentQuestion.value?.roundType ??
        currentIntro.value?.roundType ??
        snapshot.value.roundType;
    if (rType == 'Q2_DEFENSE' || rType == 'Q4_FINALS' || rType == 'ROUND_4') {
      return false;
    }

    final mode = snapshot.value.mode;
    if (mode == 'SINGLE' || mode == 'ONE_V_ONE') return false;

    final teams = snapshot.value.teams;
    final youTeam = teams.firstWhereOrNull((t) =>
        t.members.any((m) => m.userId == currentUserId || m.id == youParticipantId));
    final connectedTeammates = youTeam?.members.where((m) => !m.isBot).toList() ?? [];
    if (connectedTeammates.length <= 1) return false;

    if (serverCanPass.value != null) {
      return serverCanPass.value! && !hasPassed.value;
    }
    final you = snapshot.value.you;
    if (you != null && you.canPass) return true;
    return true;
  }

  bool get isShooter {
    final start = shootoutStart.value;
    if (start == null) return false;
    if (start.shooterParticipantId.isNotEmpty &&
        start.shooterParticipantId == youParticipantId) {
      return true;
    }
    if (currentUserNickname != null &&
        start.shooterName.toLowerCase() == currentUserNickname!.toLowerCase()) {
      return true;
    }
    return false;
  }

  String get shooterTeamLabel {
    final start = shootoutStart.value;
    if (start == null) return 'Team A';
    final pId = start.shooterParticipantId;
    for (final t in snapshot.value.teams) {
      if (t.members.any((m) => m.id == pId || m.userId == currentUserId)) {
        return t.label;
      }
    }
    return 'Team A';
  }

  int get shooterTeamXp {
    final start = shootoutStart.value;
    if (start == null) return 0;
    for (final t in snapshot.value.teams) {
      if (t.members.any((m) => m.id == start.shooterParticipantId)) {
        final score = teamScores[t.id];
        if (score != null) return score * 2;
        return t.scoreXp;
      }
    }
    return 0;
  }

  bool get isQ2Defense {
    final rType = currentQuestion.value?.roundType ??
        currentIntro.value?.roundType ??
        snapshot.value.roundType;
    return rType == 'Q2_DEFENSE' || rType == 'ROUND_2';
  }

  bool get isQ3Hobby {
    final rType = currentQuestion.value?.roundType ??
        currentIntro.value?.roundType ??
        snapshot.value.roundType;
    return rType == 'Q3_HOBBY' || rType == 'ROUND_3';
  }

  bool get isQ4Finals {
    final rType = currentQuestion.value?.roundType ??
        currentIntro.value?.roundType ??
        snapshot.value.roundType;
    return rType == 'Q4_FINALS' || rType == 'ROUND_4' || rType == 'Q4';
  }

  bool get isVotingActive =>
      questionSubPhase.value == QuestionSubPhase.votingActive;

  bool get canSubmitVote =>
      isVotingActive &&
      !isVoteSubmitted.value &&
      selectedVoteOptionIndex.value != null;

  void onVoteOptionTap(int index) {
    if (questionSubPhase.value != QuestionSubPhase.votingActive) return;
    if (isVoteSubmitted.value) return;
    selectedVoteOptionIndex.value = index;
    selectedOptionIndex.value = index;
  }

  void onVoteNowTap() {
    if (!canSubmitVote) return;
    final q = currentQuestion.value;
    if (q == null) return;
    final idx = selectedVoteOptionIndex.value;
    if (idx == null) return;

    isVoteSubmitted.value = true;
    _socketService.vote(
      matchId: snapshot.value.matchId,
      roundId: q.roundId,
      questionId: q.questionId,
      selectedIndex: idx,
    );

    // On a 1-person team, resolves immediately once vote is submitted without waiting for ghost teammates.
    final youTeam = snapshot.value.teams.firstWhereOrNull((t) =>
        t.members.any((m) => m.userId == currentUserId || m.id == youParticipantId));
    final connectedMembers = youTeam?.members.where((m) => !m.isBot).toList() ?? [];
    if (connectedMembers.length > 1 && voteResult.value == null) {
      questionSubPhase.value = QuestionSubPhase.voteWaitingTeammates;
    }
  }

  void onSeeTheResultTap() {
    isVoteResultRevealed.value = true;
    final vr = voteResult.value;
    if (vr != null && vr.correct) {
      // Correct vote earns the ball and triggers shootout
      Timer(const Duration(milliseconds: 1600), () {
        showVoteResultSheet.value = false;
        final q = currentQuestion.value;
        _socketService.startMockShootout(
          roundId: q?.roundId ?? 'mock-shootout-q4',
          shooterParticipantId: youParticipantId,
          shooterName: currentUserNickname ?? 'Alex',
          roundType: 'Q4_FINALS',
        );
      });
    } else {
      Timer(const Duration(milliseconds: 2000), () {
        showVoteResultSheet.value = false;
      });
    }
  }

  List<HeroPowerInfo> get usablePowerChips {
    if (!isQ3Hobby) return const [];
    final you = snapshot.value.you;
    if (you != null && you.usablePowers.isNotEmpty) {
      final list = <HeroPowerInfo>[];
      for (final code in you.usablePowers) {
        final info = HeroPowerInfo.findByPowerCode(code);
        if (info != null) list.add(info);
      }
      if (list.isNotEmpty) return list;
    }

    final yourCode = you?.powerCode;
    if (yourCode != null && yourCode.isNotEmpty) {
      final info = HeroPowerInfo.findByPowerCode(yourCode);
      if (info != null) return [info];
    }

    final mem = snapshot.value.allParticipants
        .firstWhereOrNull((p) => p.userId == currentUserId || p.id == youParticipantId);
    if (mem?.powerCode != null && mem!.powerCode!.isNotEmpty) {
      final info = HeroPowerInfo.findByPowerCode(mem.powerCode);
      if (info != null) return [info];
    }

    final heroId = you?.heroId ?? mem?.heroId;
    if (heroId != null && heroId.isNotEmpty) {
      final info = HeroPowerInfo.findByHeroIdOrCode(heroId);
      if (info != null) return [info];
    }

    final defaultInfo = HeroPowerInfo.findByPowerCode('LAB');
    return defaultInfo != null ? [defaultInfo] : const [];
  }

  bool get canUsePower {
    if (!isQ3Hobby) return false;
    if (hasUsedPower.value) return false;
    if (questionSubPhase.value != QuestionSubPhase.buzzedYou) return false;
    if (isSubmittingAnswer.value) return false;
    if (selectedOptionIndex.value != null) return false;
    return true;
  }

  void onUsePower(String powerCode) {
    if (!canUsePower) return;
    final q = currentQuestion.value;
    if (q == null) return;

    if (powerCode.toUpperCase() == 'HARMONY') {
      final teams = snapshot.value.teams;
      final isSingleOr1v1 = snapshot.value.mode == 'SINGLE' ||
          snapshot.value.mode == 'ONE_V_ONE' ||
          teams.every((t) => t.members.where((m) => !m.isBot).length <= 1);
      if (isSingleOr1v1) {
        // Harmony in 1v1 on NO_TEAMMATE shows no ask-for-help flow
        return;
      }

      hasUsedPower.value = true;
      final effectEvent = GamePowerEffectEvent.fromJson({
        'roundId': q.roundId,
        'userId': currentUserId ?? 'mock-student-id',
        'participantId': youParticipantId,
        'powerCode': 'HARMONY',
        'effect': {
          'type': 'harmony',
          'title': 'Congratulations!',
          'subtitle': 'Your teammate is here to help!',
        },
      });
      showingPowerBanner.value = effectEvent;
      _socketService.usePower(q.roundId, powerCode);
      return;
    }

    _socketService.usePower(q.roundId, powerCode);
  }

  void onAskForHelpTap() {
    final q = currentQuestion.value;
    if (q == null) return;
    showingPowerBanner.value = null;
    _socketService.requestHelp(q.roundId);
  }

  void onSendHelpSuggest(int optionIndex) {
    final req = activeHelpRequest.value;
    if (req == null) return;
    activeHelpRequest.value = null;
    _socketService.suggestHelp(
      roundId: req.roundId,
      forUserId: req.fromUserId,
      optionIndex: optionIndex,
    );
  }

  bool get canSubmitFreeText {
    return !isFreeTextSubmitted.value &&
        !isSubmittingAnswer.value &&
        freeTextAnswer.value.trim().isNotEmpty;
  }

  int getTeamCoins(int teamIndex) => getTeamKindness(teamIndex);

  int getTeamKindness(int teamIndex) {
    final teams = snapshot.value.teams;
    if (teamIndex < teams.length) {
      final t = teams[teamIndex];
      if (teamScores.containsKey('${t.id}_kindness')) {
        return teamScores['${t.id}_kindness']!;
      }
      if (t.scoreKindness > 0) {
        return t.scoreKindness;
      }
      if (teamIndex == 0) {
        return userKindnessCoins.value;
      }
      return 210; // Default Team B kindness in design
    }
    return teamIndex == 0 ? userKindnessCoins.value : 210;
  }

  String get currentRoundSubtitle {
    if (isQ2Defense) return 'Round 2';
    final rType = currentQuestion.value?.roundType ??
        currentIntro.value?.roundType ??
        snapshot.value.roundType;
    if (rType == 'Q3_HOBBY') return 'Round 3';
    if (rType == 'Q4_FINALS') return 'Round 4';
    return 'Round 1';
  }

  String get currentRoundTitle {
    if (isQ2Defense) return 'Defense Round';
    final rType = currentQuestion.value?.roundType ??
        currentIntro.value?.roundType ??
        snapshot.value.roundType;
    if (rType == 'Q3_HOBBY') return 'Hobby Hoops';
    if (rType == 'Q4_FINALS') return 'Wings Final';
    return 'Warm-Up Hoops';
  }

  @override
  void onInit() {
    super.onInit();
    freeTextController = TextEditingController();
    final firstTeam = snapshot.value.teams.firstOrNull;
    if (firstTeam != null && firstTeam.scoreKindness > 0) {
      userKindnessCoins.value = firstTeam.scoreKindness;
    }
    _initScoresFromSnapshot();
    final you = snapshot.value.you;
    if (you != null && you.powerUsed) {
      hasUsedPower.value = true;
    } else {
      final mem = snapshot.value.allParticipants
          .firstWhereOrNull((p) => p.userId == currentUserId || p.id == youParticipantId);
      if (mem != null && mem.powerUsed) {
        hasUsedPower.value = true;
      }
    }
    _listenSocketEvents();
    _startClockTicker();

    // Check if initial snapshot is already in countdown or playing
    final snapPhase = snapshot.value.phase.toUpperCase();
    if (snapPhase == 'COUNTDOWN') {
      phase.value = GamePhase.countdown;
      _activeDeadline = snapshot.value.deadlineAt ??
          DateTime.now().add(const Duration(seconds: 3));
      _updateTimerDerived();
    } else if (snapPhase == 'PLAYING') {
      phase.value = GamePhase.question;
    }
  }

  void _initScoresFromSnapshot() {
    final s = snapshot.value.scores;
    if (s != null) {
      s.forEach((k, v) {
        if (v is int) {
          teamScores[k] = v;
        } else if (v is Map) {
          final baskets = v['baskets'] ?? v['xp'] ?? 0;
          teamScores[k] = (baskets is int) ? baskets : int.tryParse('$baskets') ?? 0;
        }
      });
    }
  }

  void showPeerLeftToast(GamePeerLeftEvent event) {
    peerLeftBanner.value = event;
    _peerLeftTimer?.cancel();
    _peerLeftTimer = Timer(const Duration(seconds: 6), () {
      peerLeftBanner.value = null;
    });
  }

  void _listenSocketEvents() {
    _subscriptions.add(_socketService.onMatchFound.listen((s) {
      snapshot.value = s;
      _initScoresFromSnapshot();
    }));

    _subscriptions.add(_socketService.onSnapshot.listen((s) {
      _handleSnapshotRestore(s);
    }));

    _subscriptions.add(_socketService.onSnapshotData.listen((data) {
      _handleSnapshotRestore(snapshot.value, data);
    }));

    _subscriptions.add(_socketService.onPeerLeft.listen((event) {
      showPeerLeftToast(event);
    }));

    _subscriptions.add(_socketService.onCountdown.listen((event) {
      phase.value = GamePhase.countdown;
      countdownValue.value = event.value;
      _activeDeadline = event.deadlineAt ??
          DateTime.now().add(Duration(seconds: event.value));
      _updateTimerDerived();
    }));

    _subscriptions.add(_socketService.onRoundIntro.listen((event) {
      currentIntro.value = event;
      phase.value = GamePhase.roundIntro;
      _activeDeadline = event.deadlineAt;
      _updateTimerDerived();
    }));

    _subscriptions.add(_socketService.onQuestion.listen((event) {
      currentQuestion.value = event;
      phase.value = GamePhase.question;
      questionSubPhase.value = QuestionSubPhase.buzzerActive;
      buzzWinner.value = null;
      waiting.value = null;
      answerResult.value = null;
      stealOpen.value = null;
      selectedOptionIndex.value = null;
      isBuzzing.value = false;
      isSubmittingAnswer.value = false;

      // Reset Q2 Defense state
      freeTextAnswer.value = '';
      freeTextController.clear();
      isFreeTextSubmitted.value = false;
      isWaitingOthers.value = false;
      showKindnessCelebration.value = false;

      // Reset Q3 Power Effects for this question
      removedOptionIndices.clear();
      currentHint.value = null;
      prismWeights.clear();
      showingPowerBanner.value = null;
      _bannerTimer?.cancel();

      // Reset Q4 Voting state
      selectedVoteOptionIndex.value = null;
      isVoteSubmitted.value = false;
      showVoteResultSheet.value = false;
      isVoteResultRevealed.value = false;
      voteResult.value = null;
      voteUpdate.value = null;
      voteOpen.value = null;
      votingTeamLabel.value = null;

      // Reset Pass & Harmony Help state
      suggestedOptionIndex.value = null;
      suggestedByName.value = null;
      activeHelpRequest.value = null;
      buzzWinnerLine.value = null;
      hasPassed.value = false;
      serverCanPass.value = null;

      final defaultSec = (event.roundType == 'Q2_DEFENSE') ? 60 : 10;
      _activeDeadline = event.deadlineAt ??
          DateTime.now().add(Duration(seconds: defaultSec));
      _updateTimerDerived();
    }));

    _subscriptions.add(_socketService.onBuzzWinner.listen((event) {
      buzzWinner.value = event;

      if (isQ4Finals) {
        final youTeam = snapshot.value.teams.firstWhereOrNull((t) =>
            t.members.any((m) => m.userId == currentUserId || m.id == youParticipantId));
        final buzzingTeam = snapshot.value.teams.firstWhereOrNull((t) =>
            t.members.any((m) => m.userId == event.userId || m.id == event.participantId));

        final isYou = (event.userId.isNotEmpty && event.userId == currentUserId) ||
            (event.participantId.isNotEmpty &&
                event.participantId == youParticipantId);

        final isYourTeam = (buzzingTeam != null && youTeam != null && buzzingTeam.id == youTeam.id) || isYou;
        votingTeamLabel.value = buzzingTeam?.label ?? (isYourTeam ? (youTeam?.label ?? 'Team A') : 'Team B');

        _activeDeadline = event.deadlineAt ?? DateTime.now().add(const Duration(seconds: 20));
        _updateTimerDerived();

        if (isYourTeam) {
          questionSubPhase.value = QuestionSubPhase.votingActive;
        } else {
          questionSubPhase.value = QuestionSubPhase.voteWaitingOtherTeam;
        }
        return;
      }

      _activeDeadline = event.deadlineAt ??
          DateTime.now().add(const Duration(seconds: 10));
      _updateTimerDerived();

      final isYou = (event.userId.isNotEmpty && event.userId == currentUserId) ||
          (event.participantId.isNotEmpty &&
              event.participantId == youParticipantId);

      if (_socketService.latestCanPass.value != null) {
        serverCanPass.value = _socketService.latestCanPass.value;
      }
      if (_socketService.latestBuzzWinnerLine.value != null) {
        buzzWinnerLine.value = _socketService.latestBuzzWinnerLine.value;
      } else if (isYou && (hasPassed.value || serverCanPass.value == false) && snapshot.value.mode == 'FIVE_V_FIVE') {
        buzzWinnerLine.value = 'Your teammate passed to you';
      }

      if (isYou) {
        questionSubPhase.value = QuestionSubPhase.buzzedYou;
        isSubmittingAnswer.value = false;
      } else {
        questionSubPhase.value = QuestionSubPhase.buzzedOther;
      }
    }));

    _subscriptions.add(_socketService.onHelpRequest.listen((event) {
      final youTeam = snapshot.value.teams.firstWhereOrNull((t) =>
          t.members.any((m) => m.userId == currentUserId || m.id == youParticipantId));
      final requesterTeam = snapshot.value.teams.firstWhereOrNull((t) =>
          t.members.any((m) => m.userId == event.fromUserId));
      final isSameTeam = youTeam != null && requesterTeam != null && youTeam.id == requesterTeam.id;
      final isSelf = event.fromUserId != null &&
          (event.fromUserId == currentUserId || event.fromUserId == youParticipantId);

      if ((isSameTeam || youTeam == null) && !isSelf) {
        activeHelpRequest.value = event;
      }
    }));

    _subscriptions.add(_socketService.onHelpSuggest.listen((event) {
      if (questionSubPhase.value == QuestionSubPhase.buzzedYou) {
        suggestedOptionIndex.value = event.optionIndex;
        suggestedByName.value = event.fromNickname ?? 'Teammate';
      }
    }));

    _subscriptions.add(_socketService.onWaiting.listen((event) {
      waiting.value = event;
      if (isQ2Defense) {
        isWaitingOthers.value = true;
      } else if (isQ4Finals) {
        if (questionSubPhase.value != QuestionSubPhase.votingActive &&
            questionSubPhase.value != QuestionSubPhase.voteWaitingTeammates) {
          questionSubPhase.value = QuestionSubPhase.voteWaitingOtherTeam;
        }
      } else {
        if (questionSubPhase.value != QuestionSubPhase.buzzedYou) {
          questionSubPhase.value = QuestionSubPhase.buzzedOther;
        }
      }
    }));

    _subscriptions.add(_socketService.onVoteOpen.listen((event) {
      voteOpen.value = event;
      _activeDeadline = event.deadlineAt ?? DateTime.now().add(const Duration(seconds: 20));
      _updateTimerDerived();

      final youTeam = snapshot.value.teams.firstWhereOrNull((t) =>
          t.members.any((m) => m.userId == currentUserId || m.id == youParticipantId));
      final isYourTeam = (event.teamId != null && youTeam?.id == event.teamId) ||
          (event.teamLabel != null && youTeam?.label.toLowerCase() == event.teamLabel!.toLowerCase());

      votingTeamLabel.value = event.teamLabel ?? youTeam?.label ?? 'Team A';

      if (isYourTeam) {
        questionSubPhase.value = QuestionSubPhase.votingActive;
      } else {
        questionSubPhase.value = QuestionSubPhase.voteWaitingOtherTeam;
      }
    }));

    _subscriptions.add(_socketService.onVoteUpdate.listen((event) {
      voteUpdate.value = event;
    }));

    _subscriptions.add(_socketService.onVoteResult.listen((event) {
      voteResult.value = event;
      showVoteResultSheet.value = true;
      isVoteResultRevealed.value = false;
      questionSubPhase.value = QuestionSubPhase.voteResult;
    }));

    _subscriptions.add(_socketService.onAnswerResult.listen((event) {
      answerResult.value = event;
      questionSubPhase.value = QuestionSubPhase.answerResult;
      _updateScores(event.scores);
      if (isQ2Defense &&
          (event.kindnessDelta > 0 || event.scores.isNotEmpty)) {
        _handleKindnessResult(GameKindnessResultEvent(
          roundId: event.roundId,
          userId: event.userId,
          participantId: event.participantId,
          kindnessDelta: event.kindnessDelta,
          scores: event.scores,
        ));
      }
    }));

    _subscriptions.add(_socketService.onKindnessResult.listen((event) {
      _handleKindnessResult(event);
    }));

    _subscriptions.add(_socketService.onStealOpen.listen((event) {
      stealOpen.value = event;
      _activeDeadline = event.deadlineAt ??
          DateTime.now().add(const Duration(seconds: 10));
      _updateTimerDerived();
      questionSubPhase.value = QuestionSubPhase.stealActive;
      isBuzzing.value = false;
    }));

    _subscriptions.add(_socketService.onShootoutStart.listen((event) {
      shootoutStart.value = event;
      shootoutResult.value = null;
      hasSwiped.value = false;
      phase.value = GamePhase.shootout;
      _activeDeadline = event.deadlineAt ??
          DateTime.now().add(const Duration(seconds: 60));
      _updateTimerDerived();
    }));

    _subscriptions.add(_socketService.onShootoutResult.listen((event) {
      shootoutResult.value = event;
      if (event.teamScores.isNotEmpty) {
        _updateScores(event.teamScores);
      } else {
        if (event.teamAScoreVs != null && snapshot.value.teams.isNotEmpty) {
          teamScores[snapshot.value.teams[0].id] = event.teamAScoreVs!;
          teamScores['teamA'] = event.teamAScoreVs!;
        }
        if (event.teamBScoreVs != null && snapshot.value.teams.length > 1) {
          teamScores[snapshot.value.teams[1].id] = event.teamBScoreVs!;
          teamScores['teamB'] = event.teamBScoreVs!;
        }
      }
    }));

    _subscriptions.add(_socketService.onRoundCompleteEvent.listen((event) {
      roundComplete.value = event;
      isSubmittingAck.value = false;
      phase.value = GamePhase.roundComplete;
      _activeDeadline = event.deadlineAt;
      _updateTimerDerived();
      if (snapshot.value.teams.isNotEmpty) {
        teamScores[snapshot.value.teams[0].id] = event.teamA.scoreVs;
      }
      if (snapshot.value.teams.length > 1) {
        teamScores[snapshot.value.teams[1].id] = event.teamB.scoreVs;
      }
    }));

    _subscriptions.add(_socketService.onRoundComplete.listen((data) {
      if (roundComplete.value == null) {
        final event = GameRoundCompleteEvent.fromJson(data);
        roundComplete.value = event;
        phase.value = GamePhase.roundComplete;
      }
    }));

    _subscriptions.add(_socketService.onPowerEffect.listen((event) {
      _handlePowerEffect(event);
    }));

    _setupSocketMatchFinishedListener();
  }

  void _setupSocketMatchFinishedListener() {
    _socketService.socket?.on('match:finished', _onSocketMatchFinished);
  }

  void _handleSnapshotRestore(GameMatchSnapshot snap, [Map<String, dynamic>? rawData]) {
    debugPrint('[GamePlayController] _handleSnapshotRestore -> phase: ${snap.phase}');
    snapshot.value = snap;
    _initScoresFromSnapshot();

    final phaseStr = snap.phase.toUpperCase();
    if (phaseStr == 'FINISHED') {
      if (matchFinished.value == null) {
        finishMockMatch();
      }
      phase.value = GamePhase.complete;
      return;
    }

    if (phaseStr == 'CANCELLED') {
      _socketService.disconnect();
      Get.offAllNamed(Routes.GAME_MODE_SELECT);
      return;
    }

    if (phaseStr == 'COUNTDOWN') {
      phase.value = GamePhase.countdown;
      _activeDeadline = snap.deadlineAt ?? DateTime.now().add(const Duration(seconds: 3));
      _updateTimerDerived();
      return;
    }

    if (phaseStr == 'PLAYING') {
      GameQuestionEvent? q;
      if (rawData != null && rawData['question'] != null) {
        try {
          q = GameQuestionEvent.fromJson(Map<String, dynamic>.from(rawData['question'] as Map));
        } catch (_) {}
      }

      final effectiveQuestion = q ?? currentQuestion.value;
      if (effectiveQuestion != null) {
        currentQuestion.value = effectiveQuestion;
        phase.value = GamePhase.question;

        final effectiveDeadline = snap.deadlineAt ?? effectiveQuestion.deadlineAt;
        _activeDeadline = effectiveDeadline;
        _updateTimerDerived();

        final isDeadlinePassed = effectiveDeadline != null &&
            DateTime.now().isAfter(effectiveDeadline);

        if (isDeadlinePassed) {
          // If question deadline passed while disconnected, options stay disabled until server advances.
          // The rejoining phone shows the waiting or result state and answer controls stay disabled.
          selectedOptionIndex.value = null;
          isSubmittingAnswer.value = true;
          questionSubPhase.value = QuestionSubPhase.buzzedOther;
          waiting.value = GameWaitingEvent(
            roundId: effectiveQuestion.roundId,
            reason: 'OPPONENT',
          );
        } else {
          // Restore the board, selection cleared, clock from deadlineAt
          selectedOptionIndex.value = null;
          isSubmittingAnswer.value = false;
          isBuzzing.value = false;

          if (isQ4Finals) {
            selectedVoteOptionIndex.value = null;
            isVoteSubmitted.value = false;
            questionSubPhase.value = QuestionSubPhase.votingActive;
          } else if (isQ2Defense) {
            isFreeTextSubmitted.value = false;
            isWaitingOthers.value = false;
          } else {
            final youCanBuzz = snap.you?.canBuzz ?? true;
            if (youCanBuzz) {
              questionSubPhase.value = QuestionSubPhase.buzzerActive;
            }
          }
        }
      }
    }
  }

  void _onSocketMatchFinished(dynamic data) {
    debugPrint('[GamePlayController] on match:finished -> $data');
    if (data is Map) {
      final event = GameMatchFinishedEvent.fromJson(
        Map<String, dynamic>.from(data),
        snapshot.value.teams,
      );
      matchFinished.value = event;
      phase.value = GamePhase.complete;
    }
  }

  void _handlePowerEffect(GamePowerEffectEvent event) {
    final isForYou = (event.userId != null && event.userId == currentUserId) ||
        (event.participantId != null && event.participantId == youParticipantId) ||
        questionSubPhase.value == QuestionSubPhase.buzzedYou;

    if (isForYou) {
      hasUsedPower.value = true;
      activePowerEffect.value = event;

      // Show power banner overlay (auto-dismiss for non-Harmony powers; Harmony stays until Ask for help or dismissed)
      showingPowerBanner.value = event;
      _bannerTimer?.cancel();
      if (event.powerCode.toUpperCase() != 'HARMONY') {
        _bannerTimer = Timer(const Duration(milliseconds: 2200), () {
          showingPowerBanner.value = null;
        });
      }

      // Apply effects matching plan
      if (event.removedOptions != null && event.removedOptions!.isNotEmpty) {
        removedOptionIndices.assignAll(event.removedOptions!);
      }
      if (event.deadlineAt != null) {
        _activeDeadline = event.deadlineAt;
        _updateTimerDerived();
      } else if (event.extraMs != null && event.extraMs! > 0) {
        _activeDeadline = (_activeDeadline ?? DateTime.now())
            .add(Duration(milliseconds: event.extraMs!));
        _updateTimerDerived();
      }
      if (event.hint != null && event.hint!.trim().isNotEmpty) {
        currentHint.value = event.hint!.trim();
      }
      if (event.weights != null && event.weights!.isNotEmpty) {
        prismWeights.assignAll(event.weights!);
      }
    }
  }

  void _updateScores(Map<String, dynamic> rawScores) {
    rawScores.forEach((k, v) {
      if (v is int) {
        teamScores[k] = v;
      } else if (v is Map) {
        final baskets = v['baskets'] ??
            v['score_baskets'] ??
            v['scoreBaskets'] ??
            v['xp'] ??
            0;
        final kindness =
            v['kindness'] ?? v['score_kindness'] ?? v['scoreKindness'];
        teamScores[k] =
            (baskets is int) ? baskets : int.tryParse('$baskets') ?? 0;
        if (kindness != null) {
          final kindInt =
              (kindness is int) ? kindness : int.tryParse('$kindness') ?? 0;
          teamScores['${k}_kindness'] = kindInt;
        }
      }
    });
  }

  void _handleKindnessResult(GameKindnessResultEvent event) {
    if (event.scores.isNotEmpty) {
      _updateScores(event.scores);
    }

    if (event.kindnessDelta == 50) {
      userKindnessCoins.value += 50;

      final youTeam = snapshot.value.teams.firstWhereOrNull((t) =>
          t.members.any((m) =>
              m.userId == currentUserId || m.id == youParticipantId));
      if (youTeam != null) {
        final current = teamScores['${youTeam.id}_kindness'] ??
            (youTeam.scoreKindness > 0 ? youTeam.scoreKindness : 245);
        teamScores['${youTeam.id}_kindness'] = current + 50;
      }

      isWaitingOthers.value = false;
      showKindnessCelebration.value = true;
    } else {
      isWaitingOthers.value = false;
      showKindnessCelebration.value = false;
    }
  }

  void onFreeTextChanged(String text) {
    freeTextAnswer.value = text;
  }

  void onSubmitFreeText() {
    if (!canSubmitFreeText) return;
    final text = freeTextController.text.trim();
    if (text.isEmpty) return;

    isSubmittingAnswer.value = true;
    isFreeTextSubmitted.value = true;
    isWaitingOthers.value = true;

    final q = currentQuestion.value;
    if (q != null) {
      _socketService.submitAnswer(q.roundId, freeText: text);
    }
  }

  void onPlayTheShootTap() {
    showKindnessCelebration.value = false;
    final q = currentQuestion.value;
    _socketService.startMockShootout(
      roundId: q?.roundId ?? 'mock-shootout-q2',
      shooterParticipantId: youParticipantId,
      shooterName: currentUserNickname ?? 'Alex',
      roundType: 'Q2_DEFENSE',
    );
  }

  void _startClockTicker() {
    _clockTicker?.cancel();
    _clockTicker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      _updateTimerDerived();
    });
  }

  void _updateTimerDerived() {
    final deadline = _activeDeadline;
    if (deadline == null) return;

    final diff = deadline.difference(DateTime.now()).inMilliseconds;
    final diffSec = (diff / 1000).ceil();
    final remaining = diffSec > 0 ? diffSec : 0;
    secondsLeft.value = remaining;

    if (phase.value == GamePhase.countdown) {
      if (remaining > 0 && remaining <= 3) {
        countdownValue.value = remaining;
      } else if (remaining <= 0) {
        countdownValue.value = 1;
      }
    }

    final s = remaining;
    final formatted = '00:${s.toString().padLeft(2, '0')}';
    timerString.value = formatted;
    // NOTE: Rule: "No local timer auto-advance — server drives transitions."
    // We only update the visual clock digits.
  }

  void onBuzzTap() {
    final q = currentQuestion.value;
    if (q == null || isBuzzing.value) return;
    isBuzzing.value = true;
    _socketService.buzz(q.roundId);
  }

  void onOptionTap(int index) {
    if (isQ4Finals) {
      onVoteOptionTap(index);
      return;
    }
    if (questionSubPhase.value != QuestionSubPhase.buzzedYou) return;
    if (isSubmittingAnswer.value) return;

    final q = currentQuestion.value;
    if (q == null) return;

    selectedOptionIndex.value = index;
    isSubmittingAnswer.value = true;
    _socketService.submitAnswer(q.roundId, optionIndex: index);
  }

  void onPassTap() {
    if (!canPass) return;
    final q = currentQuestion.value;
    if (q == null) return;
    hasPassed.value = true;
    serverCanPass.value = false;
    isSubmittingAnswer.value = true;
    _socketService.pass(q.roundId);
  }

  void simulateMockPass() {
    onPassTap();
  }

  void simulateMockTeammatePass() {
    final q = currentQuestion.value;
    if (q == null) return;
    _socketService.simulateMockTeammatePassToUser(roundId: q.roundId);
  }

  void simulateMockTeammateHelpRequest() {
    final q = currentQuestion.value;
    final helpReq = GameHelpRequestEvent(
      roundId: q?.roundId ?? 'mock-round-q3-1',
      fromUserId: 'user-samantha-8',
      fromNickname: 'Samantha',
      prompt: q?.prompt ?? 'Why might learning to play the violin be a rewarding hobby?',
      options: q?.options ?? const [
        'Develops musical skills and patience',
        'Guarantees becoming famous',
        'It means you never need to practice',
        'It makes everyone like the same music',
      ],
    );
    activeHelpRequest.value = helpReq;
  }

  void simulateMockTeammateSuggest({int optionIndex = 0}) {
    suggestedOptionIndex.value = optionIndex;
    suggestedByName.value = 'Mili';
  }

  void onOpenQuizTap() {
    final intro = currentIntro.value;
    final roundType = intro?.roundType ?? 'Q1_WARMUP';
    _socketService.ackIntro(roundType);
  }

  void onLeaveTap(BuildContext context) {
    GameLeaveConfirmModal.show(
      context: context,
      onConfirmLeave: () async {
        final matchId = snapshot.value.matchId;
        if (matchId.isNotEmpty) {
          _socketService.leaveMatch(matchId);
          try {
            await _repository?.leaveMatch(matchId);
          } catch (_) {}
        }
        _socketService.disconnect();
        if (Get.isRegistered<GameModeSelectController>()) {
          Get.find<GameModeSelectController>().reloadStudentStats();
        }
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchHome();
        }
        Get.offAllNamed(Routes.GAME_MODE_SELECT);
      },
    );
  }

  void onSwipeShoot({required bool made}) {
    if (!isShooter) return;
    if (hasSwiped.value) return;
    final start = shootoutStart.value;
    if (start == null) return;

    hasSwiped.value = true;
    _socketService.submitShootoutSwipe(
      roundId: start.roundId,
      made: made,
      matchId: snapshot.value.matchId,
    );
  }

  void onPlayNextRoundTap() {
    if (isSubmittingAck.value) return;
    isSubmittingAck.value = true;
    final rc = roundComplete.value;
    final isFinalRound = isQ4Finals || (rc?.roundNumber != null && rc!.roundNumber >= 4);

    if (isFinalRound) {
      if (_socketService.socket != null && _socketService.isConnected.value) {
        _socketService.ackRoundComplete(
          matchId: snapshot.value.matchId,
          roundId: rc?.roundId,
        );
      } else {
        finishMockMatch();
        isSubmittingAck.value = false;
        return;
      }
    } else {
      _socketService.ackRoundComplete(
        matchId: snapshot.value.matchId,
        roundId: rc?.roundId,
      );
    }
  }

  void finishMockMatch({
    String? winnerTeamId,
    String? winnerTeamLabel,
    bool? isTie,
  }) {
    final teamAScore = getTeamScore(0);
    final teamBScore = getTeamScore(1);
    final teamACoins = getTeamCoins(0);
    final teamBCoins = getTeamCoins(1);

    final resolvedIsTie = isTie ??
        (winnerTeamId == null
            ? (teamAScore == teamBScore && teamACoins == teamBCoins)
            : false);

    String? resolvedWinnerId;
    String? resolvedWinnerLabel;

    if (!resolvedIsTie) {
      if (winnerTeamId != null && winnerTeamId.isNotEmpty) {
        resolvedWinnerId = winnerTeamId;
        resolvedWinnerLabel = winnerTeamLabel ??
            (winnerTeamId == (snapshot.value.teams.isNotEmpty ? snapshot.value.teams[0].id : 'team-single-1')
                ? getTeamLabel(0)
                : getTeamLabel(1));
      } else {
        if (teamAScore > teamBScore || (teamAScore == teamBScore && teamACoins > teamBCoins)) {
          resolvedWinnerId = snapshot.value.teams.isNotEmpty
              ? snapshot.value.teams[0].id
              : 'team-single-1';
          resolvedWinnerLabel = getTeamLabel(0);
        } else if (teamBScore > teamAScore || (teamAScore == teamBScore && teamBCoins > teamACoins)) {
          resolvedWinnerId = snapshot.value.teams.length > 1
              ? snapshot.value.teams[1].id
              : 'team-bot-2';
          resolvedWinnerLabel = getTeamLabel(1);
        } else {
          resolvedWinnerId = null;
          resolvedWinnerLabel = null;
        }
      }
    }

    final finished = GameMatchFinishedEvent(
      matchId: snapshot.value.matchId,
      winnerTeamId: resolvedIsTie ? null : resolvedWinnerId,
      winnerTeamLabel: resolvedIsTie ? null : resolvedWinnerLabel,
      isTie: resolvedIsTie || resolvedWinnerId == null,
      teamA: GameMatchFinishedTeam(
        id: snapshot.value.teams.isNotEmpty ? snapshot.value.teams[0].id : 'team-single-1',
        label: getTeamLabel(0),
        scoreVs: teamAScore,
        coins: teamACoins,
        xp: teamAScore > 0 ? 2 : 0,
        members: snapshot.value.teams.isNotEmpty ? snapshot.value.teams[0].members : [],
      ),
      teamB: GameMatchFinishedTeam(
        id: snapshot.value.teams.length > 1 ? snapshot.value.teams[1].id : 'team-bot-2',
        label: getTeamLabel(1),
        scoreVs: teamBScore,
        coins: teamBCoins,
        xp: teamBScore > 0 ? 2 : 0,
        members: snapshot.value.teams.length > 1 ? snapshot.value.teams[1].members : [],
      ),
    );

    matchFinished.value = finished;
    phase.value = GamePhase.complete;
  }

  void simulateMatchFinished({
    String? winnerTeamId,
    String? winnerTeamLabel,
    bool? isTie,
  }) {
    finishMockMatch(
      winnerTeamId: winnerTeamId,
      winnerTeamLabel: winnerTeamLabel,
      isTie: isTie,
    );
  }

  void simulatePeerLeft({
    String? userId,
    String? nickname,
    String? avatarUrl,
  }) {
    final opponent = snapshot.value.teams.length > 1 &&
            snapshot.value.teams[1].members.isNotEmpty
        ? snapshot.value.teams[1].members.first
        : null;

    final peerEvent = GamePeerLeftEvent(
      userId: userId ?? opponent?.userId ?? 'bot-user',
      nickname: nickname ?? opponent?.nickname ?? 'Practice Bot',
      avatarUrl: avatarUrl ?? opponent?.avatarUrl,
    );
    showPeerLeftToast(peerEvent);
  }

  void simulateForfeit({
    String? winningTeamId,
    String? winningTeamLabel,
  }) {
    final youTeamId = snapshot.value.teams.isNotEmpty
        ? snapshot.value.teams[0].id
        : 'team-single-1';
    final youTeamLabel = getTeamLabel(0);

    finishMockMatch(
      winnerTeamId: winningTeamId ?? youTeamId,
      winnerTeamLabel: winningTeamLabel ?? youTeamLabel,
      isTie: false,
    );
  }

  void simulateMockDrop({Duration gracePeriod = const Duration(seconds: 15)}) {
    _socketService.isConnected.value = false;
    _mockGraceTimer?.cancel();
    _mockGraceTimer = Timer(gracePeriod, () {
      simulatePeerLeft();
    });
  }

  void simulateMockReconnect([GameMatchSnapshot? customSnapshot, Map<String, dynamic>? rawData]) {
    _mockGraceTimer?.cancel();
    _socketService.isConnected.value = true;
    if (customSnapshot != null) {
      _handleSnapshotRestore(customSnapshot, rawData);
    } else {
      _handleSnapshotRestore(snapshot.value, rawData);
    }
  }

  void onBackToLobby() {
    final matchId = snapshot.value.matchId;
    if (matchId.isNotEmpty) {
      try {
        _socketService.leaveMatch(matchId);
      } catch (_) {}
      try {
        _repository?.leaveMatch(matchId);
      } catch (_) {}
    }
    _socketService.disconnect();

    if (Get.isRegistered<GameModeSelectController>()) {
      Get.find<GameModeSelectController>().reloadStudentStats();
    }
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().fetchHome();
    }

    Get.offAllNamed(Routes.GAME_MODE_SELECT);
  }

  void onLeaderboardTap() {
    Get.toNamed(Routes.LEADERBOARD);
  }

  void onPowersTap(BuildContext context) {
    GamePowerWingsSheet.show(
      context: context,
      isQ3: isQ3Hobby,
      snapshot: snapshot.value,
      currentUserId: currentUserId,
      youParticipantId: youParticipantId,
    );
  }

  int getTeamScore(int teamIndex) {
    final teams = snapshot.value.teams;
    if (teamIndex < teams.length) {
      final t = teams[teamIndex];
      if (teamScores.containsKey(t.id)) {
        return teamScores[t.id]!;
      }
      if (teamIndex == 0 && teamScores.containsKey('teamA')) {
        return teamScores['teamA']!;
      }
      if (teamIndex == 1 && teamScores.containsKey('teamB')) {
        return teamScores['teamB']!;
      }
      return t.scoreBaskets;
    }
    return 0;
  }

  String getTeamLabel(int teamIndex) {
    final teams = snapshot.value.teams;
    if (teamIndex < teams.length) {
      return teams[teamIndex].label;
    }
    return teamIndex == 0 ? 'Team A' : 'Team B';
  }

  bool isTeamActive(int teamIndex) {
    final teams = snapshot.value.teams;
    if (teamIndex >= teams.length) return false;
    final team = teams[teamIndex];

    if (isQ4Finals) {
      if (votingTeamLabel.value != null && votingTeamLabel.value!.isNotEmpty) {
        return team.label.toLowerCase() == votingTeamLabel.value!.toLowerCase();
      }
      if (questionSubPhase.value == QuestionSubPhase.votingActive) {
        return team.members.any((m) => m.userId == currentUserId || m.id == youParticipantId);
      }
      if (questionSubPhase.value == QuestionSubPhase.voteWaitingOtherTeam) {
        return !team.members.any((m) => m.userId == currentUserId || m.id == youParticipantId);
      }
    }

    if (questionSubPhase.value == QuestionSubPhase.buzzedYou) {
      // You are active -> check if you belong to this team
      return team.members.any((m) => m.userId == currentUserId || m.id == youParticipantId);
    } else if (questionSubPhase.value == QuestionSubPhase.buzzedOther) {
      final bw = buzzWinner.value;
      if (bw != null) {
        return team.members.any((m) => m.userId == bw.userId || m.id == bw.participantId);
      }
      final w = waiting.value;
      if (w != null && w.teamLabel != null) {
        return team.label.toLowerCase() == w.teamLabel!.toLowerCase();
      }
      return teamIndex == 1; // Default opponent
    }
    return false;
  }

  @override
  void onClose() {
    try {
      _socketService.socket?.off('match:finished');
    } catch (_) {}
    _clockTicker?.cancel();
    _bannerTimer?.cancel();
    _peerLeftTimer?.cancel();
    _mockGraceTimer?.cancel();
    freeTextController.dispose();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.onClose();
  }
}
