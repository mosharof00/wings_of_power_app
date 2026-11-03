import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:wings_of_power_app/app/core/config/app_config.dart';
import 'package:wings_of_power_app/app/core/services/secure_storage_service.dart';
import '../models/game_match.dart';

class GameSocketService extends GetxService {
  io.Socket? _socket;

  final isConnected = false.obs;
  final isConnecting = false.obs;
  final lastError = RxnString();

  final latestMatch = Rxn<GameMatchSnapshot>();
  final latestSnapshot = Rxn<GameMatchSnapshot>();
  final latestQueueUpdate = Rxn<GameQueueUpdate>();
  final latestCountdown = Rxn<GameCountdownEvent>();
  final latestRoundIntro = Rxn<GameRoundIntroEvent>();
  final latestQuestion = Rxn<GameQuestionEvent>();
  final latestBuzzWinner = Rxn<GameBuzzWinnerEvent>();
  final latestWaiting = Rxn<GameWaitingEvent>();
  final latestAnswerResult = Rxn<GameAnswerResultEvent>();
  final latestStealOpen = Rxn<GameStealOpenEvent>();
  final latestRoundComplete = Rxn<Map<String, dynamic>>();
  final latestShootoutStart = Rxn<GameShootoutStartEvent>();
  final latestShootoutResult = Rxn<GameShootoutResultEvent>();
  final latestRoundCompleteEvent = Rxn<GameRoundCompleteEvent>();

  final _matchFoundController = StreamController<GameMatchSnapshot>.broadcast();
  Stream<GameMatchSnapshot> get onMatchFound => _matchFoundController.stream;

  final _snapshotController = StreamController<GameMatchSnapshot>.broadcast();
  Stream<GameMatchSnapshot> get onSnapshot => _snapshotController.stream;

  final _queueUpdateController = StreamController<GameQueueUpdate>.broadcast();
  Stream<GameQueueUpdate> get onQueueUpdate => _queueUpdateController.stream;

  final _countdownController = StreamController<GameCountdownEvent>.broadcast();
  Stream<GameCountdownEvent> get onCountdown => _countdownController.stream;

  final _roundIntroController = StreamController<GameRoundIntroEvent>.broadcast();
  Stream<GameRoundIntroEvent> get onRoundIntro => _roundIntroController.stream;

  final _questionController = StreamController<GameQuestionEvent>.broadcast();
  Stream<GameQuestionEvent> get onQuestion => _questionController.stream;

  final _buzzWinnerController = StreamController<GameBuzzWinnerEvent>.broadcast();
  Stream<GameBuzzWinnerEvent> get onBuzzWinner => _buzzWinnerController.stream;

  final _waitingController = StreamController<GameWaitingEvent>.broadcast();
  Stream<GameWaitingEvent> get onWaiting => _waitingController.stream;

  final _answerResultController = StreamController<GameAnswerResultEvent>.broadcast();
  Stream<GameAnswerResultEvent> get onAnswerResult => _answerResultController.stream;

  final _stealOpenController = StreamController<GameStealOpenEvent>.broadcast();
  Stream<GameStealOpenEvent> get onStealOpen => _stealOpenController.stream;

  final _roundCompleteController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onRoundComplete => _roundCompleteController.stream;

  final _shootoutStartController = StreamController<GameShootoutStartEvent>.broadcast();
  Stream<GameShootoutStartEvent> get onShootoutStart => _shootoutStartController.stream;

  final _shootoutResultController = StreamController<GameShootoutResultEvent>.broadcast();
  Stream<GameShootoutResultEvent> get onShootoutResult => _shootoutResultController.stream;

  final _roundCompleteEventController = StreamController<GameRoundCompleteEvent>.broadcast();
  Stream<GameRoundCompleteEvent> get onRoundCompleteEvent => _roundCompleteEventController.stream;

  Timer? _mockTimer;
  Timer? _mockBotTimer;
  Timer? _mockShootoutTimer;

  io.Socket? get socket => _socket;

  static String resolveSocketUrl([String? overrideUrl]) {
    if (overrideUrl != null && overrideUrl.isNotEmpty) {
      return overrideUrl;
    }
    final domain = AppConfig.domainUrl;
    final uri = Uri.tryParse(domain);
    if (uri != null && uri.hasPort) {
      return domain;
    }
    // If domain has localhost / 127.0.0.1 / 10.0.2.2 without port, default to :3000
    if (domain.contains('localhost') ||
        domain.contains('127.0.0.1') ||
        domain.contains('10.0.2.2')) {
      return '$domain:3000';
    }
    return domain;
  }

  Future<void> connect({String? customToken, String? customUrl}) async {
    if (isConnected.value && _socket != null) {
      return;
    }

    isConnecting.value = true;
    lastError.value = null;

    final token = customToken ??
        await SecureStorageService.instance.getToken() ??
        (AppConfig.useMocks ? 'mock-student-jwt-token' : null);

    final url = resolveSocketUrl(customUrl);

    try {
      _cleanupSocket();

      final options = io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token ?? ''})
          .setExtraHeaders({'Authorization': 'Bearer ${token ?? ''}'})
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .build();

      _socket = io.io(url, options);

      _socket?.onConnect((_) {
        debugPrint('[GameSocketService] Connected to $url');
        isConnected.value = true;
        isConnecting.value = false;
        lastError.value = null;
      });

      _socket?.onDisconnect((reason) {
        debugPrint('[GameSocketService] Disconnected: $reason');
        isConnected.value = false;
        isConnecting.value = false;
      });

      _socket?.onConnectError((err) {
        debugPrint('[GameSocketService] Connect error: $err');
        isConnected.value = false;
        isConnecting.value = false;
        lastError.value = err?.toString() ?? 'Connection error';
      });

      _socket?.onError((err) {
        debugPrint('[GameSocketService] Socket error: $err');
        lastError.value = err?.toString();
      });

      _socket?.on('match:found', (data) {
        debugPrint('[GameSocketService] match:found: $data');
        if (data is Map) {
          final snapshot =
              GameMatchSnapshot.fromJson(Map<String, dynamic>.from(data));
          latestMatch.value = snapshot;
          _matchFoundController.add(snapshot);
        }
      });

      _socket?.on('match:snapshot', (data) {
        debugPrint('[GameSocketService] match:snapshot: $data');
        if (data is Map) {
          final snapshot =
              GameMatchSnapshot.fromJson(Map<String, dynamic>.from(data));
          latestSnapshot.value = snapshot;
          latestMatch.value = snapshot;
          _snapshotController.add(snapshot);
        }
      });

      _socket?.on('queue:update', (data) {
        debugPrint('[GameSocketService] queue:update: $data');
        if (data is Map) {
          final update =
              GameQueueUpdate.fromJson(Map<String, dynamic>.from(data));
          latestQueueUpdate.value = update;
          _queueUpdateController.add(update);
        }
      });

      _socket?.on('queue:error', (data) {
        debugPrint('[GameSocketService] queue:error: $data');
        if (data is Map && data['message'] != null) {
          lastError.value = data['message'].toString();
        } else {
          lastError.value = data?.toString();
        }
      });

      _socket?.on('match:error', (data) {
        debugPrint('[GameSocketService] match:error: $data');
        if (data is Map && data['message'] != null) {
          lastError.value = data['message'].toString();
        } else {
          lastError.value = data?.toString();
        }
      });

      _socket?.on('match:countdown', (data) {
        debugPrint('[GameSocketService] match:countdown: $data');
        if (data is Map) {
          final event =
              GameCountdownEvent.fromJson(Map<String, dynamic>.from(data));
          latestCountdown.value = event;
          _countdownController.add(event);
        }
      });

      _socket?.on('round:intro', (data) {
        debugPrint('[GameSocketService] round:intro: $data');
        if (data is Map) {
          final event =
              GameRoundIntroEvent.fromJson(Map<String, dynamic>.from(data));
          latestRoundIntro.value = event;
          _roundIntroController.add(event);
        }
      });

      _socket?.on('round:question', (data) {
        debugPrint('[GameSocketService] round:question: $data');
        if (data is Map) {
          final event =
              GameQuestionEvent.fromJson(Map<String, dynamic>.from(data));
          latestQuestion.value = event;
          _questionController.add(event);
        }
      });

      _socket?.on('round:buzz_winner', (data) {
        debugPrint('[GameSocketService] round:buzz_winner: $data');
        if (data is Map) {
          final event =
              GameBuzzWinnerEvent.fromJson(Map<String, dynamic>.from(data));
          latestBuzzWinner.value = event;
          _buzzWinnerController.add(event);
        }
      });

      _socket?.on('round:waiting', (data) {
        debugPrint('[GameSocketService] round:waiting: $data');
        if (data is Map) {
          final event =
              GameWaitingEvent.fromJson(Map<String, dynamic>.from(data));
          latestWaiting.value = event;
          _waitingController.add(event);
        }
      });

      _socket?.on('round:answer_result', (data) {
        debugPrint('[GameSocketService] round:answer_result: $data');
        if (data is Map) {
          final event =
              GameAnswerResultEvent.fromJson(Map<String, dynamic>.from(data));
          latestAnswerResult.value = event;
          _answerResultController.add(event);
        }
      });

      _socket?.on('round:steal_open', (data) {
        debugPrint('[GameSocketService] round:steal_open: $data');
        if (data is Map) {
          final event =
              GameStealOpenEvent.fromJson(Map<String, dynamic>.from(data));
          latestStealOpen.value = event;
          _stealOpenController.add(event);
        }
      });

      _socket?.on('shootout:start', (data) {
        debugPrint('[GameSocketService] shootout:start: $data');
        if (data is Map) {
          final event =
              GameShootoutStartEvent.fromJson(Map<String, dynamic>.from(data));
          latestShootoutStart.value = event;
          _shootoutStartController.add(event);
        }
      });

      _socket?.on('shootout:result', (data) {
        debugPrint('[GameSocketService] shootout:result: $data');
        if (data is Map) {
          final event =
              GameShootoutResultEvent.fromJson(Map<String, dynamic>.from(data));
          latestShootoutResult.value = event;
          _shootoutResultController.add(event);
        }
      });

      _socket?.on('round:complete', (data) {
        debugPrint('[GameSocketService] round:complete: $data');
        if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          latestRoundComplete.value = map;
          _roundCompleteController.add(map);
          final event = GameRoundCompleteEvent.fromJson(map);
          latestRoundCompleteEvent.value = event;
          _roundCompleteEventController.add(event);
        }
      });

      _socket?.connect();
    } catch (e) {
      debugPrint('[GameSocketService] Exception while connecting: $e');
      isConnecting.value = false;
      lastError.value = e.toString();
    }
  }

  void joinQueue(String mode, [String? fixtureCode]) {
    _socket?.emit('queue:join', {
      'mode': mode,
      if (fixtureCode != null && fixtureCode.isNotEmpty)
        'fixtureCode': fixtureCode,
    });
  }

  void cancelQueue() {
    _socket?.emit('queue:cancel', {});
  }

  void requestSnapshot([String? matchId]) {
    _socket?.emit('match:snapshot', {
      'matchId': ?matchId,
    });
  }

  void leaveMatch(String matchId) {
    _socket?.emit('match:leave', {'matchId': matchId});
  }

  void buzz(String roundId) {
    debugPrint('[GameSocketService] buzz -> roundId: $roundId');
    if (_socket != null && isConnected.value) {
      _socket?.emit('round:buzz', {'roundId': roundId});
    } else {
      // Mock mode: handle human buzz
      _handleMockHumanBuzz(roundId);
    }
  }

  void submitAnswer(String roundId, {int? optionIndex, String? freeText}) {
    debugPrint('[GameSocketService] submitAnswer -> roundId: $roundId, option: $optionIndex');
    if (_socket != null && isConnected.value) {
      _socket?.emit('round:answer', {
        'roundId': roundId,
        'optionIndex': ?optionIndex,
        'freeText': ?freeText,
      });
    } else {
      // Mock mode: evaluate mock answer
      _handleMockAnswer(roundId, optionIndex);
    }
  }

  void pass(String roundId) {
    debugPrint('[GameSocketService] pass -> roundId: $roundId');
    if (_socket != null && isConnected.value) {
      _socket?.emit('round:pass', {'roundId': roundId});
    }
  }

  void ackIntro(String roundType) {
    debugPrint('[GameSocketService] ackIntro -> roundType: $roundType');
    if (_socket != null && isConnected.value) {
      _socket?.emit('round:intro_ack', {'roundType': roundType});
    } else {
      // In mock mode, immediately launch question
      _mockTimer?.cancel();
      _startMockQuestion();
    }
  }

  void submitShootoutSwipe({
    required String roundId,
    required bool made,
    String? matchId,
  }) {
    debugPrint('[GameSocketService] submitShootoutSwipe -> roundId: $roundId, made: $made');
    if (_socket != null && isConnected.value) {
      _socket?.emit('shootout:swipe', {
        if (matchId != null && matchId.isNotEmpty) 'matchId': matchId,
        'roundId': roundId,
        'made': made,
      });
    } else {
      // Mock mode: evaluate mock shootout swipe
      _handleMockShootoutSwipe(roundId: roundId, made: made);
    }
  }

  void ackRoundComplete({
    required String matchId,
    String? roundId,
  }) {
    debugPrint('[GameSocketService] ackRoundComplete -> matchId: $matchId, roundId: $roundId');
    if (_socket != null && isConnected.value) {
      _socket?.emit('round:next_ack', {
        'matchId': matchId,
        if (roundId != null && roundId.isNotEmpty) 'roundId': roundId,
      });
      _socket?.emit('round:advance', {
        'matchId': matchId,
      });
    } else {
      _handleMockRoundAdvance(matchId: matchId);
    }
  }

  /// Simulate mock match for offline testing
  void simulateMockMatch({
    String mode = 'SINGLE',
    String? fixtureCode,
    String? currentUserId,
    String? currentUserNickname,
  }) {
    final youId = currentUserId ?? 'mock-student-id';
    final youNick = currentUserNickname ?? 'Alex';

    final mock = GameMatchSnapshot(
      matchId: 'practice-${DateTime.now().millisecondsSinceEpoch}',
      mode: mode,
      phase: 'COUNTDOWN',
      deadlineAt: DateTime.now().add(const Duration(seconds: 3)),
      serverNow: DateTime.now(),
      teams: [
        GameMatchTeam(
          id: 'team-single-1',
          label: 'Team A',
          scoreXp: 0,
          scoreKindness: 0,
          scoreBaskets: 0,
          members: [
            GameMatchParticipant(
              id: 'part-you-1',
              userId: youId,
              nickname: youNick,
              avatarUrl: 'assets/images/avatar_01.png',
              heroId: 'faith',
              jerseyNumber: 1,
              isConnected: true,
              isBot: false,
            ),
          ],
        ),
        const GameMatchTeam(
          id: 'team-bot-2',
          label: 'Team B',
          scoreXp: 0,
          scoreKindness: 0,
          scoreBaskets: 0,
          members: [
            GameMatchParticipant(
              id: 'part-bot-1',
              userId: null,
              nickname: 'Practice Bot',
              avatarUrl: null,
              heroId: 'harold',
              jerseyNumber: 2,
              isConnected: true,
              isBot: true,
            ),
          ],
        ),
      ],
      you: const GameMatchYou(
        participantId: 'part-you-1',
        canBuzz: true,
        powerUsed: false,
        jerseyNumber: 1,
        canPass: false,
      ),
    );
    latestMatch.value = mock;
    latestSnapshot.value = mock;
    _matchFoundController.add(mock);

    // Kick off full mock flow
    startMockGameFlow(matchId: mock.matchId, youId: youId);
  }

  void startMockGameFlow({required String matchId, required String youId}) {
    _mockTimer?.cancel();
    _mockBotTimer?.cancel();

    // 1. Emit Countdown
    final countdown = GameCountdownEvent(
      matchId: matchId,
      deadlineAt: DateTime.now().add(const Duration(seconds: 3)),
      value: 3,
    );
    latestCountdown.value = countdown;
    _countdownController.add(countdown);

    // 2. After 3s countdown -> emit Round Intro
    _mockTimer = Timer(const Duration(seconds: 3), () {
      final intro = GameRoundIntroEvent(
        roundType: 'Q1_WARMUP',
        title: 'Warm-Up Hoops',
        blurb: 'Answer fast and earn balls for the Shootout',
        deadlineAt: DateTime.now().add(const Duration(seconds: 10)),
      );
      latestRoundIntro.value = intro;
      _roundIntroController.add(intro);

      // Auto-advance after 3s if not acknowledged
      _mockTimer = Timer(const Duration(seconds: 3), () {
        _startMockQuestion();
      });
    });
  }

  void _startMockQuestion() {
    _mockTimer?.cancel();
    _mockBotTimer?.cancel();

    final q = GameQuestionEvent(
      roundId: 'mock-round-q1-1',
      prompt: "A classmate drops their books. What's the kind thing to do?",
      options: [
        'Walk past',
        'Help them to pick',
        'Laugh',
        'Take Photo',
      ],
      roundType: 'Q1_WARMUP',
      index: 1,
      total: 5,
      deadlineAt: DateTime.now().add(const Duration(seconds: 10)),
    );
    latestQuestion.value = q;
    _questionController.add(q);

    // Bot buzz logic per D22: If nobody buzzes by 7s, bot buzzes!
    _mockBotTimer = Timer(const Duration(seconds: 7), () {
      if (latestBuzzWinner.value?.roundId != q.roundId) {
        // Bot wins buzz!
        final botWinner = GameBuzzWinnerEvent(
          roundId: q.roundId,
          participantId: 'part-bot-1',
          userId: 'bot-user',
          deadlineAt: DateTime.now().add(const Duration(seconds: 10)),
        );
        latestBuzzWinner.value = botWinner;
        _buzzWinnerController.add(botWinner);

        final wait = GameWaitingEvent(
          roundId: q.roundId,
          reason: 'OPPONENT',
          playerName: 'Practice Bot',
          teamLabel: 'Team B',
        );
        latestWaiting.value = wait;
        _waitingController.add(wait);

        // 2s later: bot answers correctly (option 1)
        _mockBotTimer = Timer(const Duration(seconds: 2), () {
          final res = GameAnswerResultEvent(
            roundId: q.roundId,
            participantId: 'part-bot-1',
            userId: 'bot-user',
            correct: true,
            optionIndex: 1,
            scores: {
              'team-single-1': {'xp': 0, 'kindness': 0, 'baskets': 0},
              'team-bot-2': {'xp': 10, 'kindness': 0, 'baskets': 1},
            },
          );
          latestAnswerResult.value = res;
          _answerResultController.add(res);

          _mockTimer = Timer(const Duration(seconds: 2), () {
            _startMockShootout(
              roundId: 'mock-shootout-q1',
              shooterParticipantId: 'part-bot-1',
              shooterName: 'Practice Bot',
            );
          });
        });
      }
    });
  }

  void _handleMockHumanBuzz(String roundId) {
    _mockBotTimer?.cancel();
    final youWinner = GameBuzzWinnerEvent(
      roundId: roundId,
      participantId: 'part-you-1',
      userId: latestMatch.value?.teams.firstOrNull?.members.firstOrNull?.userId ?? 'mock-student-id',
      deadlineAt: DateTime.now().add(const Duration(seconds: 10)),
    );
    latestBuzzWinner.value = youWinner;
    _buzzWinnerController.add(youWinner);
  }

  void _handleMockAnswer(String roundId, int? optionIndex) {
    _mockBotTimer?.cancel();
    final isCorrect = optionIndex == 1; // "Help them to pick" is correct

    final res = GameAnswerResultEvent(
      roundId: roundId,
      participantId: 'part-you-1',
      userId: latestMatch.value?.teams.firstOrNull?.members.firstOrNull?.userId ?? 'mock-student-id',
      correct: isCorrect,
      optionIndex: optionIndex,
      scores: {
        'team-single-1': {'xp': isCorrect ? 10 : 0, 'kindness': 0, 'baskets': isCorrect ? 1 : 0},
        'team-bot-2': {'xp': 0, 'kindness': 0, 'baskets': 0},
      },
    );
    latestAnswerResult.value = res;
    _answerResultController.add(res);

    if (isCorrect) {
      // Alex earned a ball! Start shootout
      _mockTimer = Timer(const Duration(seconds: 2), () {
        _startMockShootout(
          roundId: 'mock-shootout-q1',
          shooterParticipantId: 'part-you-1',
          shooterName: latestMatch.value?.teams.firstOrNull?.members.firstOrNull?.nickname ?? 'Alex',
        );
      });
    } else {
      // If wrong answer, open steal window for bot / other team!
      _mockTimer = Timer(const Duration(milliseconds: 1200), () {
        final steal = GameStealOpenEvent(
          roundId: roundId,
          deadlineAt: DateTime.now().add(const Duration(seconds: 10)),
          eligibleTeamId: 'team-bot-2',
        );
        latestStealOpen.value = steal;
        _stealOpenController.add(steal);

        // Bot steals at 3s and answers correctly
        _mockBotTimer = Timer(const Duration(seconds: 3), () {
          final botWinner = GameBuzzWinnerEvent(
            roundId: roundId,
            participantId: 'part-bot-1',
            userId: 'bot-user',
            deadlineAt: DateTime.now().add(const Duration(seconds: 10)),
          );
          latestBuzzWinner.value = botWinner;
          _buzzWinnerController.add(botWinner);

          final wait = GameWaitingEvent(
            roundId: roundId,
            reason: 'OPPONENT',
            playerName: 'Practice Bot',
            teamLabel: 'Team B',
          );
          latestWaiting.value = wait;
          _waitingController.add(wait);

          _mockBotTimer = Timer(const Duration(seconds: 2), () {
            final stealResult = GameAnswerResultEvent(
              roundId: roundId,
              participantId: 'part-bot-1',
              userId: 'bot-user',
              correct: true,
              optionIndex: 1,
              scores: {
                'team-single-1': {'xp': 0, 'kindness': 0, 'baskets': 0},
                'team-bot-2': {'xp': 10, 'kindness': 0, 'baskets': 1},
              },
            );
            latestAnswerResult.value = stealResult;
            _answerResultController.add(stealResult);

            _mockTimer = Timer(const Duration(seconds: 2), () {
              _startMockShootout(
                roundId: 'mock-shootout-q1',
                shooterParticipantId: 'part-bot-1',
                shooterName: 'Practice Bot',
              );
            });
          });
        });
      });
    }
  }

  void _startMockShootout({
    required String roundId,
    required String shooterParticipantId,
    required String shooterName,
  }) {
    _mockTimer?.cancel();
    _mockBotTimer?.cancel();
    _mockShootoutTimer?.cancel();

    final deadline = DateTime.now().add(const Duration(seconds: 60));
    final start = GameShootoutStartEvent(
      roundId: roundId,
      shooterParticipantId: shooterParticipantId,
      shooterName: shooterName,
      deadlineAt: deadline,
    );
    latestShootoutStart.value = start;
    _shootoutStartController.add(start);

    final isBot = shooterParticipantId == 'part-bot-1';
    if (isBot) {
      // Bot auto-swipes after 2.5s with made: true per D22 / T-BE-GAME-004
      _mockBotTimer = Timer(const Duration(milliseconds: 2500), () {
        _handleMockShootoutSwipe(
          roundId: roundId,
          made: true,
          isBot: true,
        );
      });
    } else {
      // Human shooter: timeout after 60s
      _mockShootoutTimer = Timer(const Duration(seconds: 60), () {
        _handleMockShootoutSwipe(
          roundId: roundId,
          made: false,
          isBot: false,
        );
      });
    }
  }

  void _handleMockShootoutSwipe({
    required String roundId,
    required bool made,
    bool isBot = false,
  }) {
    _mockShootoutTimer?.cancel();
    _mockBotTimer?.cancel();

    final xp = made ? 2 : 0;
    final vsDelta = made ? 3 : 0;
    final teamAScore = isBot ? 0 : (made ? 3 : 0);
    final teamBScore = isBot ? (made ? 3 : 0) : 0;

    final result = GameShootoutResultEvent(
      participantId: isBot ? 'part-bot-1' : 'part-you-1',
      made: made,
      xpEarned: xp,
      scoreVsDelta: vsDelta,
      teamAScoreVs: teamAScore,
      teamBScoreVs: teamBScore,
      teamScores: {
        'team-single-1': {
          'xp': isBot ? 0 : xp,
          'kindness': 0,
          'baskets': isBot ? 0 : (made ? 1 : 0),
          'scoreVs': teamAScore,
        },
        'team-bot-2': {
          'xp': isBot ? xp : 0,
          'kindness': 0,
          'baskets': isBot ? (made ? 1 : 0) : 0,
          'scoreVs': teamBScore,
        },
      },
    );
    latestShootoutResult.value = result;
    _shootoutResultController.add(result);

    // After 2.5s banner presentation -> advance to round complete
    _mockTimer = Timer(const Duration(milliseconds: 2500), () {
      final complete = GameRoundCompleteEvent(
        roundNumber: 1,
        roundId: roundId,
        roundType: 'Q1_WARMUP',
        teamA: GameRoundTeamSummary(
          name: 'Team A',
          scoreVs: teamAScore,
          coins: 245,
          xp: isBot ? 0 : xp,
        ),
        teamB: GameRoundTeamSummary(
          name: 'Team B',
          scoreVs: teamBScore,
          coins: 245,
          xp: isBot ? xp : 0,
        ),
        deadlineAt: DateTime.now().add(const Duration(seconds: 15)),
      );
      final completeMap = complete.toJson();
      latestRoundComplete.value = completeMap;
      _roundCompleteController.add(completeMap);
      latestRoundCompleteEvent.value = complete;
      _roundCompleteEventController.add(complete);
    });
  }

  void _handleMockRoundAdvance({required String matchId}) {
    _mockTimer?.cancel();
    final intro = GameRoundIntroEvent(
      roundType: 'Q2_DEFENSE',
      title: 'Defense Round',
      blurb: 'Share your kindness. There are no wrong answers.',
      deadlineAt: DateTime.now().add(const Duration(seconds: 10)),
    );
    latestRoundIntro.value = intro;
    _roundIntroController.add(intro);
  }

  void _cleanupSocket() {
    _mockTimer?.cancel();
    _mockBotTimer?.cancel();
    _mockShootoutTimer?.cancel();
    try {
      _socket?.off('connect');
      _socket?.off('disconnect');
      _socket?.off('connect_error');
      _socket?.off('error');
      _socket?.off('match:found');
      _socket?.off('match:snapshot');
      _socket?.off('queue:update');
      _socket?.off('queue:error');
      _socket?.off('match:error');
      _socket?.off('match:countdown');
      _socket?.off('round:intro');
      _socket?.off('round:question');
      _socket?.off('round:buzz_winner');
      _socket?.off('round:waiting');
      _socket?.off('round:answer_result');
      _socket?.off('round:steal_open');
      _socket?.off('round:complete');
      _socket?.off('shootout:start');
      _socket?.off('shootout:result');
      _socket?.disconnect();
      _socket?.dispose();
    } catch (_) {}
    _socket = null;
    isConnected.value = false;
    isConnecting.value = false;
  }

  void disconnect() {
    _cleanupSocket();
  }

  @override
  void onClose() {
    disconnect();
    _matchFoundController.close();
    _snapshotController.close();
    _queueUpdateController.close();
    _countdownController.close();
    _roundIntroController.close();
    _questionController.close();
    _buzzWinnerController.close();
    _waitingController.close();
    _answerResultController.close();
    _stealOpenController.close();
    _roundCompleteController.close();
    _shootoutStartController.close();
    _shootoutResultController.close();
    _roundCompleteEventController.close();
    super.onClose();
  }
}
