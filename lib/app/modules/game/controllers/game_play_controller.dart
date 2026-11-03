import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/models/game_match.dart';
import 'package:wings_of_power_app/app/data/repositories/igame_repository.dart';
import 'package:wings_of_power_app/app/data/services/game_socket_service.dart';
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
  final teamScores = <String, int>{}.obs;

  // Q2 Defense Round
  final freeTextAnswer = ''.obs;
  late final TextEditingController freeTextController;
  final isFreeTextSubmitted = false.obs;
  final isWaitingOthers = false.obs;
  final showKindnessCelebration = false.obs;
  final userKindnessCoins = 245.obs;

  // Shootout & Round Complete
  final shootoutStart = Rxn<GameShootoutStartEvent>();
  final shootoutResult = Rxn<GameShootoutResultEvent>();
  final roundComplete = Rxn<GameRoundCompleteEvent>();
  final hasSwiped = false.obs;
  final isSubmittingAck = false.obs;

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
    final you = snapshot.value.you;
    if (you != null && you.canPass) return true;
    // By rule: disabled for 1v1 and bot matches
    final teams = snapshot.value.teams;
    if (teams.length <= 1 &&
        (teams.firstOrNull?.members.length ?? 0) <= 1) {
      return false;
    }
    final youTeam = teams.firstWhereOrNull((t) =>
        t.members.any((m) => m.userId == currentUserId || m.id == youParticipantId));
    if (youTeam != null && youTeam.members.where((m) => !m.isBot).length > 1) {
      return you?.canPass ?? true;
    }
    return false;
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

  bool get canSubmitFreeText {
    return !isFreeTextSubmitted.value &&
        !isSubmittingAnswer.value &&
        freeTextAnswer.value.trim().isNotEmpty;
  }

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

  void _listenSocketEvents() {
    _subscriptions.add(_socketService.onMatchFound.listen((s) {
      snapshot.value = s;
      _initScoresFromSnapshot();
    }));

    _subscriptions.add(_socketService.onSnapshot.listen((s) {
      snapshot.value = s;
      _initScoresFromSnapshot();
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

      final defaultSec = (event.roundType == 'Q2_DEFENSE') ? 60 : 10;
      _activeDeadline = event.deadlineAt ??
          DateTime.now().add(Duration(seconds: defaultSec));
      _updateTimerDerived();
    }));

    _subscriptions.add(_socketService.onBuzzWinner.listen((event) {
      buzzWinner.value = event;
      _activeDeadline = event.deadlineAt ??
          DateTime.now().add(const Duration(seconds: 10));
      _updateTimerDerived();

      final isYou = (event.userId.isNotEmpty && event.userId == currentUserId) ||
          (event.participantId.isNotEmpty &&
              event.participantId == youParticipantId);

      if (isYou) {
        questionSubPhase.value = QuestionSubPhase.buzzedYou;
      } else {
        questionSubPhase.value = QuestionSubPhase.buzzedOther;
      }
    }));

    _subscriptions.add(_socketService.onWaiting.listen((event) {
      waiting.value = event;
      if (isQ2Defense) {
        isWaitingOthers.value = true;
      } else {
        if (questionSubPhase.value != QuestionSubPhase.buzzedYou) {
          questionSubPhase.value = QuestionSubPhase.buzzedOther;
        }
      }
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
    _socketService.pass(q.roundId);
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
        Get.back();
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
    _socketService.ackRoundComplete(
      matchId: snapshot.value.matchId,
      roundId: rc?.roundId,
    );
  }

  void onPowersTap(BuildContext context) {
    GamePowerWingsSheet.show(context: context);
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
    _clockTicker?.cancel();
    freeTextController.dispose();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.onClose();
  }
}
