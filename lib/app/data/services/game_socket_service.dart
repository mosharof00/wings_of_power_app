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
  final latestKindnessResult = Rxn<GameKindnessResultEvent>();
  final latestPowerEffect = Rxn<GamePowerEffectEvent>();
  final latestVoteOpen = Rxn<GameVoteOpenEvent>();
  final latestVoteUpdate = Rxn<GameVoteUpdateEvent>();
  final latestVoteResult = Rxn<GameVoteResultEvent>();
  final latestQueueError = Rxn<Map<String, dynamic>>();

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

  final _kindnessResultController = StreamController<GameKindnessResultEvent>.broadcast();
  Stream<GameKindnessResultEvent> get onKindnessResult => _kindnessResultController.stream;

  final _powerEffectController = StreamController<GamePowerEffectEvent>.broadcast();
  Stream<GamePowerEffectEvent> get onPowerEffect => _powerEffectController.stream;

  final _voteOpenController = StreamController<GameVoteOpenEvent>.broadcast();
  Stream<GameVoteOpenEvent> get onVoteOpen => _voteOpenController.stream;

  final _voteUpdateController = StreamController<GameVoteUpdateEvent>.broadcast();
  Stream<GameVoteUpdateEvent> get onVoteUpdate => _voteUpdateController.stream;

  final _voteResultController = StreamController<GameVoteResultEvent>.broadcast();
  Stream<GameVoteResultEvent> get onVoteResult => _voteResultController.stream;

  final _queueErrorController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onQueueError => _queueErrorController.stream;

  Timer? _mockTimer;
  Timer? _mockBotTimer;
  Timer? _mockShootoutTimer;
  bool _mockPowerUsed = false;

  int _mockCurrentRound = 1;
  int _mockQ4QuestionIndex = 1;
  String _mockRoundType = 'Q1_WARMUP';
  int _mockTeamACoins = 245;
  int _mockTeamBCoins = 245;
  int _mockTeamAScoreVs = 0;
  int _mockTeamBScoreVs = 0;
  int _mockTeamAXp = 0;
  int _mockTeamBXp = 0;

  io.Socket? get socket => _socket;

  String get _mockOpponentParticipantId =>
      (latestMatch.value?.teams.length ?? 0) >= 2 &&
              (latestMatch.value?.teams[1].members.isNotEmpty ?? false)
          ? (latestMatch.value!.teams[1].members.first.id ?? 'part-bot-1')
          : 'part-bot-1';

  String get _mockOpponentUserId =>
      (latestMatch.value?.teams.length ?? 0) >= 2 &&
              (latestMatch.value?.teams[1].members.isNotEmpty ?? false)
          ? (latestMatch.value!.teams[1].members.first.userId ?? 'bot-user')
          : 'bot-user';

  String get _mockOpponentNickname =>
      (latestMatch.value?.teams.length ?? 0) >= 2 &&
              (latestMatch.value?.teams[1].members.isNotEmpty ?? false)
          ? (latestMatch.value!.teams[1].members.first.nickname ?? 'Practice Bot')
          : 'Practice Bot';

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
        if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          latestQueueError.value = map;
          _queueErrorController.add(map);
          if (map['message'] != null) {
            lastError.value = map['message'].toString();
          } else {
            lastError.value = data.toString();
          }
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

          if (data.containsKey('kindnessDelta') ||
              data.containsKey('kindness_delta') ||
              event.kindnessDelta > 0) {
            final kindnessEvent = GameKindnessResultEvent(
              roundId: event.roundId,
              userId: event.userId,
              participantId: event.participantId,
              kindnessDelta: event.kindnessDelta,
              scores: event.scores,
            );
            latestKindnessResult.value = kindnessEvent;
            _kindnessResultController.add(kindnessEvent);
          }
        }
      });

      _socket?.on('round:kindness_result', (data) {
        debugPrint('[GameSocketService] round:kindness_result: $data');
        if (data is Map) {
          final event = GameKindnessResultEvent.fromJson(
              Map<String, dynamic>.from(data));
          latestKindnessResult.value = event;
          _kindnessResultController.add(event);
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

      _socket?.on('power:effect', (data) {
        debugPrint('[GameSocketService] power:effect: $data');
        if (data is Map) {
          final event =
              GamePowerEffectEvent.fromJson(Map<String, dynamic>.from(data));
          latestPowerEffect.value = event;
          _powerEffectController.add(event);
        }
      });

      _socket?.on('round:vote_open', (data) {
        debugPrint('[GameSocketService] round:vote_open: $data');
        if (data is Map) {
          final event =
              GameVoteOpenEvent.fromJson(Map<String, dynamic>.from(data));
          latestVoteOpen.value = event;
          _voteOpenController.add(event);
        }
      });

      _socket?.on('round:vote_update', (data) {
        debugPrint('[GameSocketService] round:vote_update: $data');
        if (data is Map) {
          final event =
              GameVoteUpdateEvent.fromJson(Map<String, dynamic>.from(data));
          latestVoteUpdate.value = event;
          _voteUpdateController.add(event);
        }
      });

      _socket?.on('round:vote_result', (data) {
        debugPrint('[GameSocketService] round:vote_result: $data');
        if (data is Map) {
          final event =
              GameVoteResultEvent.fromJson(Map<String, dynamic>.from(data));
          latestVoteResult.value = event;
          _voteResultController.add(event);
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

  void startMatch(String matchId) {
    debugPrint('[GameSocketService] startMatch -> matchId: $matchId');
    if (_socket != null && isConnected.value) {
      _socket?.emit('match:start', {'matchId': matchId});
    }
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
    debugPrint('[GameSocketService] submitAnswer -> roundId: $roundId, option: $optionIndex, freeText: $freeText');
    if (_socket != null && isConnected.value) {
      _socket?.emit('round:answer', {
        'roundId': roundId,
        'optionIndex': ?optionIndex,
        'freeText': ?freeText,
      });
    } else {
      if (freeText != null) {
        _handleMockFreeTextAnswer(roundId, freeText);
      } else {
        _handleMockAnswer(roundId, optionIndex);
      }
    }
  }

  void vote({
    required String matchId,
    required String roundId,
    String? questionId,
    required int selectedIndex,
  }) {
    debugPrint('[GameSocketService] vote -> roundId: $roundId, option: $selectedIndex');
    if (_socket != null && isConnected.value) {
      _socket?.emit('round:vote', {
        'matchId': matchId,
        'roundId': roundId,
        if (questionId != null && questionId.isNotEmpty) 'questionId': questionId,
        'selectedIndex': selectedIndex,
        'optionIndex': selectedIndex,
      });
    } else {
      _handleMockVote(
        matchId: matchId,
        roundId: roundId,
        questionId: questionId,
        selectedIndex: selectedIndex,
      );
    }
  }

  void pass(String roundId) {
    debugPrint('[GameSocketService] pass -> roundId: $roundId');
    if (_socket != null && isConnected.value) {
      _socket?.emit('round:pass', {'roundId': roundId});
    }
  }

  void usePower(String roundId, String powerCode) {
    debugPrint('[GameSocketService] usePower -> roundId: $roundId, powerCode: $powerCode');
    if (_socket != null && isConnected.value) {
      _socket?.emit('power:use', {
        'roundId': roundId,
        'powerCode': powerCode,
      });
    } else {
      _handleMockPowerUse(roundId, powerCode);
    }
  }

  void ackIntro(String roundType) {
    debugPrint('[GameSocketService] ackIntro -> roundType: $roundType');
    if (_socket != null && isConnected.value) {
      _socket?.emit('round:intro_ack', {'roundType': roundType});
    } else {
      _mockTimer?.cancel();
      if (roundType == 'Q2_DEFENSE') {
        _startMockQ2Question();
      } else if (roundType == 'Q3_HOBBY') {
        _startMockQ3Question();
      } else if (roundType == 'Q4_FINALS' || roundType == 'ROUND_4') {
        _startMockQ4Question(questionIndex: 1);
      } else {
        _startMockQuestion();
      }
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
    String? opponentNickname,
    String? opponentAvatarUrl,
  }) {
    final youId = currentUserId ?? 'mock-student-id';
    final youNick = currentUserNickname ?? 'Alex';
    final is1v1 = (mode == 'ONE_V_ONE');

    _mockPowerUsed = false;

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
              heroId: 'harold',
              heroName: 'Harold',
              powerCode: 'LAB',
              powerLabel: 'Lab Shot',
              jerseyNumber: 1,
              isConnected: true,
              isBot: false,
            ),
          ],
        ),
        GameMatchTeam(
          id: is1v1 ? 'team-opp-2' : 'team-bot-2',
          label: 'Team B',
          scoreXp: 0,
          scoreKindness: 0,
          scoreBaskets: 0,
          members: [
            GameMatchParticipant(
              id: is1v1 ? 'part-opponent-2' : 'part-bot-1',
              userId: is1v1 ? 'user-opponent-peer' : null,
              nickname: is1v1
                  ? (opponentNickname ?? 'Mili')
                  : 'Practice Bot',
              avatarUrl: is1v1
                  ? (opponentAvatarUrl ?? 'assets/images/avatar_02.png')
                  : null,
              heroId: 'faith',
              heroName: 'Faith',
              powerCode: 'MELODY',
              powerLabel: 'Melody Shot',
              jerseyNumber: 2,
              isConnected: true,
              isBot: !is1v1,
            ),
          ],
        ),
      ],
      you: const GameMatchYou(
        participantId: 'part-you-1',
        canBuzz: true,
        powerUsed: false,
        heroId: 'harold',
        powerCode: 'LAB',
        powerLabel: 'Lab Shot',
        usablePowers: ['LAB'],
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
        // Opponent wins buzz
        final oppWinner = GameBuzzWinnerEvent(
          roundId: q.roundId,
          participantId: _mockOpponentParticipantId,
          userId: _mockOpponentUserId,
          deadlineAt: DateTime.now().add(const Duration(seconds: 10)),
        );
        latestBuzzWinner.value = oppWinner;
        _buzzWinnerController.add(oppWinner);

        final wait = GameWaitingEvent(
          roundId: q.roundId,
          reason: 'OPPONENT',
          playerName: _mockOpponentNickname,
          teamLabel: 'Team B',
        );
        latestWaiting.value = wait;
        _waitingController.add(wait);

        // 2s later: opponent answers correctly (option 1)
        _mockBotTimer = Timer(const Duration(seconds: 2), () {
          final res = GameAnswerResultEvent(
            roundId: q.roundId,
            participantId: _mockOpponentParticipantId,
            userId: _mockOpponentUserId,
            correct: true,
            optionIndex: 1,
            scores: {
              'team-single-1': {'xp': 0, 'kindness': 0, 'baskets': 0},
              'team-bot-2': {'xp': 10, 'kindness': 0, 'baskets': 1},
              'team-opp-2': {'xp': 10, 'kindness': 0, 'baskets': 1},
            },
          );
          latestAnswerResult.value = res;
          _answerResultController.add(res);

          _mockTimer = Timer(const Duration(seconds: 2), () {
            _startMockShootout(
              roundId: 'mock-shootout-q1',
              shooterParticipantId: _mockOpponentParticipantId,
              shooterName: _mockOpponentNickname,
            );
          });
        });
      }
    });
  }

  void _handleMockHumanBuzz(String roundId) {
    _mockBotTimer?.cancel();
    final isQ4 = (_mockRoundType == 'Q4_FINALS');
    final youWinner = GameBuzzWinnerEvent(
      roundId: roundId,
      participantId: 'part-you-1',
      userId: latestMatch.value?.teams.firstOrNull?.members.firstOrNull?.userId ?? 'mock-student-id',
      deadlineAt: DateTime.now().add(Duration(seconds: isQ4 ? 20 : 10)),
    );
    latestBuzzWinner.value = youWinner;
    _buzzWinnerController.add(youWinner);

    if (isQ4) {
      final voteOpen = GameVoteOpenEvent(
        roundId: roundId,
        teamId: 'team-single-1',
        teamLabel: 'Team A',
        deadlineAt: DateTime.now().add(const Duration(seconds: 20)),
        durationSec: 20,
      );
      latestVoteOpen.value = voteOpen;
      _voteOpenController.add(voteOpen);

      _mockTimer?.cancel();
      _mockTimer = Timer(const Duration(seconds: 20), () {
        _handleMockQ4VoteTimeout(roundId);
      });
    }
  }

  void _handleMockVote({
    required String matchId,
    required String roundId,
    String? questionId,
    required int selectedIndex,
  }) {
    _mockTimer?.cancel();
    _mockBotTimer?.cancel();

    debugPrint('[GameSocketService] _handleMockVote -> roundId: $roundId, option: $selectedIndex');

    // On a 1-person team, resolves immediately once vote is submitted without waiting for ghost teammates
    final voteUpdate = GameVoteUpdateEvent(
      roundId: roundId,
      submittedCount: 1,
      teamSize: 1,
    );
    latestVoteUpdate.value = voteUpdate;
    _voteUpdateController.add(voteUpdate);

    final q = latestQuestion.value;
    final isCorrect = (selectedIndex == 0);
    const letters = ['A', 'B', 'C', 'D'];
    final chosenLetter = (selectedIndex >= 0 && selectedIndex < letters.length)
        ? letters[selectedIndex]
        : selectedIndex.toString();
    const correctLetter = 'A';
    final correctText = (q != null && q.options.isNotEmpty) ? q.options[0] : '';

    final voteRes = GameVoteResultEvent(
      roundId: roundId,
      winningOptionIndex: selectedIndex,
      chosenLetter: chosenLetter,
      correct: isCorrect,
      correctLetter: correctLetter,
      correctAnswerText: correctText,
      teamLabel: 'Team A',
      designatedShooterId: isCorrect ? 'part-you-1' : null,
      tallies: {selectedIndex.toString(): 1},
    );
    latestVoteResult.value = voteRes;
    _voteResultController.add(voteRes);

    if (isCorrect) {
      // Correct vote earns shootout opportunity
      // Sheet "See the Result!" will trigger shootout from controller or auto-trigger after 2s
      _mockTimer = Timer(const Duration(milliseconds: 2500), () {
        if (latestShootoutStart.value?.roundId != 'mock-shootout-q4-$_mockQ4QuestionIndex') {
          _startMockShootout(
            roundId: 'mock-shootout-q4-$_mockQ4QuestionIndex',
            shooterParticipantId: 'part-you-1',
            shooterName: latestMatch.value?.teams.firstOrNull?.members.firstOrNull?.nickname ?? 'Alex',
            roundType: 'Q4_FINALS',
          );
        }
      });
    } else {
      // Wrong vote: moves to next question after 2.5s without shootout
      _mockTimer = Timer(const Duration(milliseconds: 2500), () {
        if (_mockQ4QuestionIndex < 3) {
          _startMockQ4Question(questionIndex: _mockQ4QuestionIndex + 1);
        } else {
          _handleMockQ4Complete(roundId);
        }
      });
    }
  }

  void _handleMockQ4VoteTimeout(String roundId) {
    debugPrint('[GameSocketService] Mock Q4 vote timeout for $roundId');
    final voteRes = GameVoteResultEvent(
      roundId: roundId,
      winningOptionIndex: null,
      chosenLetter: '-',
      correct: false,
      correctLetter: 'A',
      correctAnswerText: latestQuestion.value?.options.firstOrNull ?? '',
      teamLabel: 'Team A',
      designatedShooterId: null,
      tallies: const {},
    );
    latestVoteResult.value = voteRes;
    _voteResultController.add(voteRes);

    _mockTimer = Timer(const Duration(milliseconds: 2500), () {
      if (_mockQ4QuestionIndex < 3) {
        _startMockQ4Question(questionIndex: _mockQ4QuestionIndex + 1);
      } else {
        _handleMockQ4Complete(roundId);
      }
    });
  }

  void _handleMockQ4Complete(String roundId) {
    final complete = GameRoundCompleteEvent(
      roundNumber: 4,
      roundId: roundId,
      roundType: 'Q4_FINALS',
      teamA: GameRoundTeamSummary(
        name: 'Team A',
        scoreVs: _mockTeamAScoreVs,
        coins: _mockTeamACoins,
        xp: _mockTeamAXp,
      ),
      teamB: GameRoundTeamSummary(
        name: 'Team B',
        scoreVs: _mockTeamBScoreVs,
        coins: _mockTeamBCoins,
        xp: _mockTeamBXp,
      ),
      deadlineAt: DateTime.now().add(const Duration(seconds: 15)),
    );
    latestRoundComplete.value = complete.toJson();
    _roundCompleteController.add(complete.toJson());
    latestRoundCompleteEvent.value = complete;
    _roundCompleteEventController.add(complete);
  }

  void _startMockQ4Question({int questionIndex = 1}) {
    _mockTimer?.cancel();
    _mockBotTimer?.cancel();
    _mockCurrentRound = 4;
    _mockRoundType = 'Q4_FINALS';
    _mockQ4QuestionIndex = questionIndex;

    final List<Map<String, dynamic>> q4Questions = [
      {
        'prompt': 'What is one benefit of reading books?',
        'options': [
          'Build imagination and learn new things',
          'Every story has the same ending',
          'Never need to ask questions',
          'Every book is easy',
        ],
        'correctIndex': 0,
        'correctLetter': 'A',
      },
      {
        'prompt': 'How can you support a classmate who is feeling left out?',
        'options': [
          'Invite them to join your group and listen',
          'Look the other way and walk past',
          'Tell them they should play alone',
          'Laugh with others',
        ],
        'correctIndex': 0,
        'correctLetter': 'A',
      },
      {
        'prompt': 'What makes a sports team truly strong and united?',
        'options': [
          'Encouraging each other and showing good sportsmanship',
          'Blaming each other for mistakes',
          'Only passing the ball to your best friend',
          'Ignoring the coach and teammates',
        ],
        'correctIndex': 0,
        'correctLetter': 'A',
      },
    ];

    final qData =
        q4Questions[(questionIndex - 1).clamp(0, q4Questions.length - 1)];
    final roundId = 'mock-round-q4-$questionIndex';

    final q = GameQuestionEvent(
      roundId: roundId,
      prompt: qData['prompt'] as String,
      options: List<String>.from(qData['options'] as List),
      roundType: 'Q4_FINALS',
      index: questionIndex,
      total: 3,
      deadlineAt: DateTime.now().add(const Duration(seconds: 10)),
    );
    latestQuestion.value = q;
    _questionController.add(q);

    // Bot buzz logic per D22: If nobody buzzes by 7s, bot buzzes
    _mockBotTimer = Timer(const Duration(seconds: 7), () {
      if (latestBuzzWinner.value?.roundId != q.roundId) {
        final botWinner = GameBuzzWinnerEvent(
          roundId: q.roundId,
          participantId: 'part-bot-1',
          userId: 'bot-user',
          deadlineAt: DateTime.now().add(const Duration(seconds: 20)),
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

        final voteOpen = GameVoteOpenEvent(
          roundId: q.roundId,
          teamId: 'team-bot-2',
          teamLabel: 'Team B',
          deadlineAt: DateTime.now().add(const Duration(seconds: 20)),
          durationSec: 20,
        );
        latestVoteOpen.value = voteOpen;
        _voteOpenController.add(voteOpen);

        // Bot votes at +2s
        _mockBotTimer = Timer(const Duration(seconds: 2), () {
          final voteUpdate = GameVoteUpdateEvent(
            roundId: q.roundId,
            submittedCount: 1,
            teamSize: 1,
          );
          latestVoteUpdate.value = voteUpdate;
          _voteUpdateController.add(voteUpdate);

          final voteRes = GameVoteResultEvent(
            roundId: q.roundId,
            winningOptionIndex: 0,
            chosenLetter: 'A',
            correct: true,
            correctLetter: 'A',
            correctAnswerText: (qData['options'] as List)[0],
            teamLabel: 'Team B',
            designatedShooterId: 'part-bot-1',
            tallies: {'0': 1},
          );
          latestVoteResult.value = voteRes;
          _voteResultController.add(voteRes);

          _mockTimer = Timer(const Duration(seconds: 2), () {
            _startMockShootout(
              roundId: 'mock-shootout-q4-$questionIndex',
              shooterParticipantId: 'part-bot-1',
              shooterName: 'Practice Bot',
              roundType: 'Q4_FINALS',
            );
          });
        });
      }
    });
  }

  void _handleMockAnswer(String roundId, int? optionIndex) {
    _mockBotTimer?.cancel();
    final correctIdx = _mockRoundType == 'Q3_HOBBY' ? 0 : 1;
    final isCorrect = optionIndex == correctIdx;

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
          roundId: 'mock-shootout-${_mockRoundType.toLowerCase()}',
          shooterParticipantId: 'part-you-1',
          shooterName: latestMatch.value?.teams.firstOrNull?.members.firstOrNull?.nickname ?? 'Alex',
          roundType: _mockRoundType,
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
              optionIndex: correctIdx,
              scores: {
                'team-single-1': {'xp': 0, 'kindness': 0, 'baskets': 0},
                'team-bot-2': {'xp': 10, 'kindness': 0, 'baskets': 1},
              },
            );
            latestAnswerResult.value = stealResult;
            _answerResultController.add(stealResult);

            _mockTimer = Timer(const Duration(seconds: 2), () {
              _startMockShootout(
                roundId: 'mock-shootout-${_mockRoundType.toLowerCase()}',
                shooterParticipantId: 'part-bot-1',
                shooterName: 'Practice Bot',
                roundType: _mockRoundType,
              );
            });
          });
        });
      });
    }
  }

  void _startMockQ2Question() {
    _mockTimer?.cancel();
    _mockBotTimer?.cancel();
    _mockCurrentRound = 2;
    _mockRoundType = 'Q2_DEFENSE';

    final q = GameQuestionEvent(
      roundId: 'mock-round-q2-1',
      prompt:
          'Harold loves science. At lunch, some kids laugh at him and call him a nerd. You are sitting nearby.',
      options: const [],
      roundType: 'Q2_DEFENSE',
      index: 1,
      total: 1,
      deadlineAt: DateTime.now().add(const Duration(seconds: 60)),
    );
    latestQuestion.value = q;
    _questionController.add(q);

    // Timeout after 60s if no text submitted
    _mockTimer = Timer(const Duration(seconds: 60), () {
      _handleMockQ2Timeout(q.roundId);
    });
  }

  void _handleMockFreeTextAnswer(String roundId, String freeText) {
    _mockTimer?.cancel();
    final isNonEmpty = freeText.trim().isNotEmpty;
    final kindnessDelta = isNonEmpty ? 50 : 0;

    if (isNonEmpty) {
      _mockTeamACoins += 50;
    }
    // Practice bot always completes kindness sentence (+50)
    _mockTeamBCoins += 50;

    // 1. Immediately emit waiting for classmates (opponent writing)
    final wait = GameWaitingEvent(
      roundId: roundId,
      reason: 'OPPONENT',
      playerName: 'Practice Bot',
      teamLabel: 'Team B',
    );
    latestWaiting.value = wait;
    _waitingController.add(wait);

    // 2. Resolve after 2.5s
    _mockBotTimer = Timer(const Duration(milliseconds: 2500), () {
      final kindnessResult = GameKindnessResultEvent(
        roundId: roundId,
        participantId: 'part-you-1',
        userId: latestMatch.value?.teams.firstOrNull?.members.firstOrNull?.userId ??
            'mock-student-id',
        kindnessDelta: kindnessDelta,
        scores: {
          'team-single-1': {
            'xp': _mockTeamAXp,
            'kindness': _mockTeamACoins,
            'baskets': _mockTeamAScoreVs,
          },
          'team-bot-2': {
            'xp': _mockTeamBXp,
            'kindness': _mockTeamBCoins,
            'baskets': _mockTeamBScoreVs,
          },
        },
        totalKindness: _mockTeamACoins,
      );
      latestKindnessResult.value = kindnessResult;
      _kindnessResultController.add(kindnessResult);

      final answerResult = GameAnswerResultEvent(
        roundId: roundId,
        participantId: 'part-you-1',
        userId: latestMatch.value?.teams.firstOrNull?.members.firstOrNull?.userId ??
            'mock-student-id',
        correct: isNonEmpty,
        kindnessDelta: kindnessDelta,
        scores: {
          'team-single-1': {
            'xp': _mockTeamAXp,
            'kindness': _mockTeamACoins,
            'baskets': _mockTeamAScoreVs,
          },
          'team-bot-2': {
            'xp': _mockTeamBXp,
            'kindness': _mockTeamBCoins,
            'baskets': _mockTeamBScoreVs,
          },
        },
      );
      latestAnswerResult.value = answerResult;
      _answerResultController.add(answerResult);
    });
  }

  void _handleMockQ2Timeout(String roundId) {
    _mockTeamBCoins += 50; // Bot gets kindness

    final kindnessResult = GameKindnessResultEvent(
      roundId: roundId,
      participantId: 'part-you-1',
      userId: latestMatch.value?.teams.firstOrNull?.members.firstOrNull?.userId ??
          'mock-student-id',
      kindnessDelta: 0,
      scores: {
        'team-single-1': {
          'xp': _mockTeamAXp,
          'kindness': _mockTeamACoins,
          'baskets': _mockTeamAScoreVs,
        },
        'team-bot-2': {
          'xp': _mockTeamBXp,
          'kindness': _mockTeamBCoins,
          'baskets': _mockTeamBScoreVs,
        },
      },
      totalKindness: _mockTeamACoins,
    );
    latestKindnessResult.value = kindnessResult;
    _kindnessResultController.add(kindnessResult);

    final answerResult = GameAnswerResultEvent(
      roundId: roundId,
      participantId: 'part-you-1',
      userId: latestMatch.value?.teams.firstOrNull?.members.firstOrNull?.userId ??
          'mock-student-id',
      correct: false,
      kindnessDelta: 0,
      scores: {
        'team-single-1': {
          'xp': _mockTeamAXp,
          'kindness': _mockTeamACoins,
          'baskets': _mockTeamAScoreVs,
        },
        'team-bot-2': {
          'xp': _mockTeamBXp,
          'kindness': _mockTeamBCoins,
          'baskets': _mockTeamBScoreVs,
        },
      },
    );
    latestAnswerResult.value = answerResult;
    _answerResultController.add(answerResult);

    // Bot shoots since bot answered
    _mockTimer = Timer(const Duration(seconds: 2), () {
      startMockShootout(
        roundId: 'mock-shootout-q2',
        shooterParticipantId: 'part-bot-1',
        shooterName: 'Practice Bot',
        roundType: 'Q2_DEFENSE',
      );
    });
  }

  void startMockShootout({
    required String roundId,
    required String shooterParticipantId,
    required String shooterName,
    String? roundType,
  }) {
    _startMockShootout(
      roundId: roundId,
      shooterParticipantId: shooterParticipantId,
      shooterName: shooterName,
      roundType: roundType,
    );
  }

  void _startMockShootout({
    required String roundId,
    required String shooterParticipantId,
    required String shooterName,
    String? roundType,
  }) {
    _mockTimer?.cancel();
    _mockBotTimer?.cancel();
    _mockShootoutTimer?.cancel();

    if (roundType != null) {
      _mockRoundType = roundType;
      if (roundType == 'Q2_DEFENSE') {
        _mockCurrentRound = 2;
      }
    }

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
    final isOpponent = shooterParticipantId == _mockOpponentParticipantId;
    if (isBot || isOpponent) {
      // Bot / Opponent auto-swipes after 2.5s with made: true per D22 / T-BE-GAME-004
      _mockBotTimer = Timer(const Duration(milliseconds: 2500), () {
        _handleMockShootoutSwipe(
          roundId: roundId,
          made: true,
          isBot: isBot,
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
    if (isBot || latestShootoutStart.value?.shooterParticipantId == _mockOpponentParticipantId) {
      _mockTeamBXp += xp;
      _mockTeamBScoreVs += vsDelta;
    } else {
      _mockTeamAXp += xp;
      _mockTeamAScoreVs += vsDelta;
    }

    final isOpp = latestShootoutStart.value?.shooterParticipantId == _mockOpponentParticipantId;
    final result = GameShootoutResultEvent(
      participantId: isBot
          ? 'part-bot-1'
          : (isOpp ? _mockOpponentParticipantId : 'part-you-1'),
      made: made,
      xpEarned: xp,
      scoreVsDelta: vsDelta,
      teamAScoreVs: _mockTeamAScoreVs,
      teamBScoreVs: _mockTeamBScoreVs,
      teamScores: {
        'team-single-1': {
          'xp': _mockTeamAXp,
          'kindness': _mockTeamACoins,
          'baskets': _mockTeamAScoreVs,
          'scoreVs': _mockTeamAScoreVs,
        },
        'team-bot-2': {
          'xp': _mockTeamBXp,
          'kindness': _mockTeamBCoins,
          'baskets': _mockTeamBScoreVs,
          'scoreVs': _mockTeamBScoreVs,
        },
      },
    );
    latestShootoutResult.value = result;
    _shootoutResultController.add(result);

    // After 2.5s banner presentation -> advance
    _mockTimer = Timer(const Duration(milliseconds: 2500), () {
      if (_mockRoundType == 'Q4_FINALS') {
        if (_mockQ4QuestionIndex < 3) {
          _startMockQ4Question(questionIndex: _mockQ4QuestionIndex + 1);
        } else {
          _handleMockQ4Complete(roundId);
        }
        return;
      }

      final complete = GameRoundCompleteEvent(
        roundNumber: _mockCurrentRound,
        roundId: roundId,
        roundType: _mockRoundType,
        teamA: GameRoundTeamSummary(
          name: 'Team A',
          scoreVs: _mockTeamAScoreVs,
          coins: _mockTeamACoins,
          xp: _mockTeamAXp,
        ),
        teamB: GameRoundTeamSummary(
          name: 'Team B',
          scoreVs: _mockTeamBScoreVs,
          coins: _mockTeamBCoins,
          xp: _mockTeamBXp,
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
    if (_mockCurrentRound == 1) {
      _mockCurrentRound = 2;
      _mockRoundType = 'Q2_DEFENSE';
      final intro = GameRoundIntroEvent(
        roundType: 'Q2_DEFENSE',
        title: 'Defense Round',
        blurb: 'Share your kindness. There are no wrong answers.',
        deadlineAt: DateTime.now().add(const Duration(seconds: 10)),
      );
      latestRoundIntro.value = intro;
      _roundIntroController.add(intro);
    } else if (_mockCurrentRound == 2) {
      _mockCurrentRound = 3;
      _mockRoundType = 'Q3_HOBBY';
      final intro = GameRoundIntroEvent(
        roundType: 'Q3_HOBBY',
        title: 'Hobby Hoops',
        blurb: 'Use your Power Wing once to help your team',
        deadlineAt: DateTime.now().add(const Duration(seconds: 10)),
      );
      latestRoundIntro.value = intro;
      _roundIntroController.add(intro);
    } else {
      _mockCurrentRound = 4;
      _mockRoundType = 'Q4_FINALS';
      _mockQ4QuestionIndex = 1;
      final intro = GameRoundIntroEvent(
        roundType: 'Q4_FINALS',
        title: 'Wings Final',
        blurb: 'Share your thoughts. Baskets are worth 3 points',
        deadlineAt: DateTime.now().add(const Duration(seconds: 10)),
      );
      latestRoundIntro.value = intro;
      _roundIntroController.add(intro);
    }
  }

  void _startMockQ3Question() {
    _mockTimer?.cancel();
    _mockBotTimer?.cancel();
    _mockCurrentRound = 3;
    _mockRoundType = 'Q3_HOBBY';

    final q = GameQuestionEvent(
      roundId: 'mock-round-q3-1',
      prompt: 'Why might learning to play the violin be a rewarding hobby?',
      options: [
        'Develops musical skills and patience',
        'Guarantees becoming famous',
        'It means you never need to practice',
        'It makes everyone like the same music',
      ],
      roundType: 'Q3_HOBBY',
      index: 1,
      total: 5,
      deadlineAt: DateTime.now().add(const Duration(seconds: 10)),
    );
    latestQuestion.value = q;
    _questionController.add(q);

    // Bot buzz logic per D22: If nobody buzzes by 7s, bot buzzes
    _mockBotTimer = Timer(const Duration(seconds: 7), () {
      if (latestBuzzWinner.value?.roundId != q.roundId) {
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

        _mockBotTimer = Timer(const Duration(seconds: 2), () {
          final res = GameAnswerResultEvent(
            roundId: q.roundId,
            participantId: 'part-bot-1',
            userId: 'bot-user',
            correct: true,
            optionIndex: 0,
            scores: {
              'team-single-1': {'xp': _mockTeamAXp, 'kindness': _mockTeamACoins, 'baskets': _mockTeamAScoreVs},
              'team-bot-2': {'xp': _mockTeamBXp + 10, 'kindness': _mockTeamBCoins, 'baskets': _mockTeamBScoreVs + 1},
            },
          );
          latestAnswerResult.value = res;
          _answerResultController.add(res);

          _mockTimer = Timer(const Duration(seconds: 2), () {
            _startMockShootout(
              roundId: 'mock-shootout-q3',
              shooterParticipantId: 'part-bot-1',
              shooterName: 'Practice Bot',
              roundType: 'Q3_HOBBY',
            );
          });
        });
      }
    });
  }

  void _handleMockPowerUse(String roundId, String powerCode) {
    if (_mockPowerUsed) {
      debugPrint('[GameSocketService] Mock power already used; ignoring');
      return;
    }
    if (powerCode.toUpperCase() == 'HARMONY') {
      // 1v1 / solo match: NO_TEAMMATE
      debugPrint('[GameSocketService] Mock Harmony in solo/1v1: NO_TEAMMATE');
      return;
    }
    _mockPowerUsed = true;

    Map<String, dynamic> effectMap;
    switch (powerCode.toUpperCase()) {
      case 'LAB':
        effectMap = {
          'type': 'removedOptions',
          'value': [1, 2],
        };
        break;
      case 'CHECKMATE':
        effectMap = {
          'type': 'removedOptions',
          'value': [2],
        };
        break;
      case 'MELODY':
      case 'COLOR':
        effectMap = {
          'type': 'extraMs',
          'value': 10000,
        };
        break;
      case 'NATURE':
        effectMap = {
          'type': 'hint',
          'value': 'Think about patience, discipline and expressing yourself.',
        };
        break;
      case 'STORY':
        effectMap = {
          'type': 'hint',
          'value': 'Practicing an instrument rewards you with lasting creativity.',
        };
        break;
      case 'PRISM':
        effectMap = {
          'type': 'weights',
          'value': [65, 15, 10, 10],
        };
        break;
      default:
        effectMap = {'type': 'none', 'value': null};
        break;
    }

    final youParticipant = latestMatch.value?.teams.firstOrNull?.members.firstOrNull;
    final effectEvent = GamePowerEffectEvent.fromJson({
      'roundId': roundId,
      'userId': youParticipant?.userId ?? 'mock-student-id',
      'participantId': youParticipant?.id ?? 'part-you-1',
      'powerCode': powerCode,
      'effect': effectMap,
      if (effectMap['type'] == 'extraMs')
        'deadlineAt': DateTime.now().add(const Duration(seconds: 18)).toIso8601String(),
    });
    latestPowerEffect.value = effectEvent;
    _powerEffectController.add(effectEvent);
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
      _socket?.off('round:kindness_result');
      _socket?.off('round:steal_open');
      _socket?.off('round:complete');
      _socket?.off('shootout:start');
      _socket?.off('shootout:result');
      _socket?.off('power:effect');
      _socket?.off('round:vote_open');
      _socket?.off('round:vote_update');
      _socket?.off('round:vote_result');
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
    _kindnessResultController.close();
    _stealOpenController.close();
    _roundCompleteController.close();
    _shootoutStartController.close();
    _shootoutResultController.close();
    _roundCompleteEventController.close();
    _powerEffectController.close();
    _voteOpenController.close();
    _voteUpdateController.close();
    _voteResultController.close();
    super.onClose();
  }
}
