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

  // Subscriptions
  final List<StreamSubscription> _subscriptions = [];

  String get youParticipantId {
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

  @override
  void onInit() {
    super.onInit();
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
      _activeDeadline = event.deadlineAt ??
          DateTime.now().add(const Duration(seconds: 10));
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
      if (questionSubPhase.value != QuestionSubPhase.buzzedYou) {
        questionSubPhase.value = QuestionSubPhase.buzzedOther;
      }
    }));

    _subscriptions.add(_socketService.onAnswerResult.listen((event) {
      answerResult.value = event;
      questionSubPhase.value = QuestionSubPhase.answerResult;
      _updateScores(event.scores);
    }));

    _subscriptions.add(_socketService.onStealOpen.listen((event) {
      stealOpen.value = event;
      _activeDeadline = event.deadlineAt ??
          DateTime.now().add(const Duration(seconds: 10));
      _updateTimerDerived();
      questionSubPhase.value = QuestionSubPhase.stealActive;
      isBuzzing.value = false;
    }));

    _subscriptions.add(_socketService.onRoundComplete.listen((data) {
      phase.value = GamePhase.complete;
    }));
  }

  void _updateScores(Map<String, dynamic> rawScores) {
    rawScores.forEach((k, v) {
      if (v is int) {
        teamScores[k] = v;
      } else if (v is Map) {
        final baskets = v['baskets'] ?? v['xp'] ?? 0;
        teamScores[k] = (baskets is int) ? baskets : int.tryParse('$baskets') ?? 0;
      }
    });
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
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.onClose();
  }
}
