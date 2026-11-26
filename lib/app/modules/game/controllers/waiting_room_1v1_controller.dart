import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/config/app_config.dart';
import 'package:wings_of_power_app/app/data/models/game_match.dart';
import 'package:wings_of_power_app/app/data/models/hero_models.dart';
import 'package:wings_of_power_app/app/data/repositories/game_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/igame_repository.dart';
import 'package:wings_of_power_app/app/data/services/game_socket_service.dart';
import 'package:wings_of_power_app/app/routes/app_pages.dart';
import '../views/game_match_hold_view.dart';

class WaitingRoom1v1Controller extends GetxController {
  WaitingRoom1v1Controller({
    this.currentUserId,
    this.currentUserNickname,
    this.currentUserAvatar,
    this.selectedHero,
    this.initialTicketId,
    this.mode = 'ONE_V_ONE',
    this.fixtureCode,
    IGameRepository? repository,
    GameSocketService? socketService,
    this.mockPeerDelay = const Duration(seconds: 4),
    this.autoSimulatePeer = true,
    this.findingTimeout = const Duration(seconds: 6),
    this.queueTimeout = const Duration(minutes: 10),
  })  : _repository = repository ??
            (Get.isRegistered<IGameRepository>()
                ? Get.find<IGameRepository>()
                : GameRepository(Get.find())),
        _socketService = socketService ??
            (Get.isRegistered<GameSocketService>()
                ? Get.find<GameSocketService>()
                : GameSocketService());

  final IGameRepository _repository;
  final GameSocketService _socketService;

  final String? currentUserId;
  final String? currentUserNickname;
  final String? currentUserAvatar;
  final HeroModel? selectedHero;
  final String? initialTicketId;
  final String mode;
  final String? fixtureCode;
  final Duration mockPeerDelay;
  final bool autoSimulatePeer;
  final Duration findingTimeout;
  final Duration queueTimeout;

  final ticketId = RxnString();
  final matchId = RxnString();

  final opponentUserId = RxnString();
  final opponentNickname = RxnString();
  final opponentAvatarUrl = RxnString();

  final statusTitle = 'Finding your classmates'.obs;
  final statusSubtitle = 'Wait for others to join'.obs;
  final isRoomFull = false.obs;
  final isStarting = false.obs;
  final isCancelled = false.obs;

  bool _hasTransitionedToMatch = false;
  final List<StreamSubscription> _subscriptions = [];
  Worker? _connectionWorker;
  Timer? _findingTimer;
  Timer? _queueExpiryTimer;
  Timer? _mockPeerTimer;

  bool get isOpponentFound =>
      opponentNickname.value != null && opponentNickname.value!.isNotEmpty;

  String get effectiveUserNickname =>
      (currentUserNickname != null && currentUserNickname!.isNotEmpty)
          ? currentUserNickname!
          : 'Sarah';

  String get effectiveUserAvatar =>
      (currentUserAvatar != null && currentUserAvatar!.isNotEmpty)
          ? currentUserAvatar!
          : 'assets/images/avatar_01.png';

  @override
  void onInit() {
    super.onInit();
    ticketId.value = initialTicketId;
    _setupListeners();
    _startFindingTimer();
    _startQueueExpiryTimer();
    _initQueue();
  }

  void _setupListeners() {
    _subscriptions.add(_socketService.onQueueUpdate.listen(_handleQueueUpdate));
    _subscriptions.add(_socketService.onMatchFound.listen(_handleMatchFound));
    _subscriptions.add(_socketService.onCountdown.listen(_handleCountdown));
    _subscriptions.add(_socketService.onSnapshot.listen(_handleSnapshot));
    _subscriptions.add(_socketService.onQueueError.listen(_handleQueueError));
  }

  Future<void> _initQueue() async {
    if (!AppConfig.useMocks) {
      _connectionWorker = ever(_socketService.isConnected, (connected) {
        if (connected) _joinQueue();
      });
      if (_socketService.isConnected.value) {
        _joinQueue();
      } else {
        await _socketService.connect();
      }
      return;
    }

    // Check if mock mode is active
    if (AppConfig.useMocks && autoSimulatePeer) {
      _startMockPeerSimulation();
    }
  }

  void _joinQueue() {
    if (!isClosed && !isCancelled.value && !_hasTransitionedToMatch) {
      _socketService.joinQueue(mode, fixtureCode);
    }
  }

  void _handleSnapshot(GameMatchSnapshot snapshot) {
    if (snapshot.mode != mode) return;
    if (snapshot.phase == 'QUEUED') {
      _handleMatchFound(snapshot);
    } else if (snapshot.phase == 'COUNTDOWN' || snapshot.phase == 'PLAYING') {
      _enterMatch(snapshot);
    }
  }

  void _startFindingTimer() {
    _findingTimer?.cancel();
    _findingTimer = Timer(findingTimeout, () {
      if (!isRoomFull.value && !isCancelled.value) {
        statusTitle.value = 'No opponent yet';
        statusSubtitle.value = 'Wait for others to join';
      }
    });
  }

  void _startQueueExpiryTimer() {
    _queueExpiryTimer?.cancel();
    _queueExpiryTimer = Timer(queueTimeout, () {
      if (!isRoomFull.value && !isCancelled.value) {
        _handleQueueTimeout();
      }
    });
  }

  void _startMockPeerSimulation() {
    _mockPeerTimer?.cancel();
    _mockPeerTimer = Timer(mockPeerDelay, () {
      if (!isRoomFull.value && !isCancelled.value) {
        simulatePeerJoin(
          nickname: 'Mili',
          avatarUrl: 'assets/images/avatar_02.png',
          userId: 'mock-peer-mili',
        );
      }
    });
  }

  void simulatePeerJoin({
    required String nickname,
    String? avatarUrl,
    String? userId,
  }) {
    if (isCancelled.value) return;
    _findingTimer?.cancel();

    opponentUserId.value = userId ?? 'peer-1';
    opponentNickname.value = nickname;
    opponentAvatarUrl.value = avatarUrl ?? 'assets/images/avatar_02.png';
    matchId.value ??= 'match-1v1-${DateTime.now().millisecondsSinceEpoch}';

    isRoomFull.value = true;
    statusTitle.value = 'Both players are ready';
    statusSubtitle.value = 'Click below to start the game';

    // Update socket latestMatch with two human players
    final snapshot = _build1v1Snapshot(
      matchId.value!,
      DateTime.now().add(const Duration(seconds: 3)),
    );
    _socketService.latestMatch.value = snapshot;
  }

  void _handleQueueUpdate(GameQueueUpdate update) {
    if (isCancelled.value) return;
    if (update.mode != mode || matchId.value != null) return;

    if (update.filled >= 2 || update.players.length >= 2) {
      _findingTimer?.cancel();
      // Find opponent member
      final myId = currentUserId ?? '';
      Map<String, dynamic>? peerMap;
      for (final p in update.players) {
        if (p is Map) {
          final pUid = p['userId']?.toString() ?? p['user_id']?.toString();
          if (pUid != myId) {
            peerMap = Map<String, dynamic>.from(p);
            break;
          }
        }
      }
      peerMap ??= update.players.length > 1 && update.players[1] is Map
          ? Map<String, dynamic>.from(update.players[1] as Map)
          : null;

      if (peerMap != null) {
        opponentUserId.value =
            peerMap['userId']?.toString() ?? peerMap['user_id']?.toString();
        opponentNickname.value =
            peerMap['nickname']?.toString() ?? 'Classmate';
        opponentAvatarUrl.value = peerMap['avatarUrl']?.toString() ??
            peerMap['avatar_url']?.toString();
      } else {
        opponentNickname.value = 'Classmate';
      }

      isRoomFull.value = true;
      statusTitle.value = 'Both players are ready';
      statusSubtitle.value = 'Click below to start the game';
    } else if (update.filled <= 1) {
      // Peer left or only self waiting
      if (isRoomFull.value) {
        opponentUserId.value = null;
        opponentNickname.value = null;
        opponentAvatarUrl.value = null;
        isRoomFull.value = false;
        statusTitle.value = 'Finding your classmates';
        statusSubtitle.value = 'Wait for others to join';
        _startFindingTimer();
      }
    }
  }

  void _handleMatchFound(GameMatchSnapshot snapshot) {
    if (isCancelled.value || snapshot.mode != mode) return;
    _findingTimer?.cancel();
    matchId.value = snapshot.matchId;

    // Find peer from teams
    final myId = currentUserId ?? '';
    for (final team in snapshot.teams) {
      for (final member in team.members) {
        if (member.userId != myId && (mode == 'SINGLE' || !member.isBot)) {
          opponentUserId.value = member.userId;
          opponentNickname.value = member.nickname;
          opponentAvatarUrl.value = member.avatarUrl;
          break;
        }
      }
    }

    if (opponentNickname.value == null || opponentNickname.value!.isEmpty) {
      opponentNickname.value = 'Classmate';
    }

    isRoomFull.value = true;
    statusTitle.value = 'Both players are ready';
    statusSubtitle.value = 'Tap to start the game';
  }

  void _handleCountdown(GameCountdownEvent event) {
    if (isCancelled.value ||
        _hasTransitionedToMatch ||
        matchId.value != event.matchId) {
      return;
    }
    GameMatchSnapshot? snapshot = _socketService.latestMatch.value;
    if (snapshot == null || snapshot.teams.isEmpty) {
      snapshot = _build1v1Snapshot(event.matchId, event.deadlineAt);
    } else {
      snapshot = GameMatchSnapshot(
        matchId: snapshot.matchId,
        mode: mode,
        phase: 'COUNTDOWN',
        deadlineAt: event.deadlineAt ??
            DateTime.now().add(Duration(seconds: event.value)),
        serverNow: DateTime.now(),
        teams: snapshot.teams,
        roundType: snapshot.roundType,
        roundId: snapshot.roundId,
        you: snapshot.you,
        scores: snapshot.scores,
      );
    }

    _enterMatch(snapshot);
  }

  void _enterMatch(GameMatchSnapshot snapshot) {
    if (isCancelled.value || _hasTransitionedToMatch) return;
    _hasTransitionedToMatch = true;
    _cleanupTimers();
    Get.off(
      () => GameMatchHoldView(
        snapshot: snapshot,
        currentUserId: currentUserId,
        currentUserNickname: currentUserNickname,
      ),
      routeName: '/game/match',
    );
  }

  void _handleQueueError(Map<String, dynamic> error) {
    final code = error['code']?.toString() ?? '';
    final message = error['message']?.toString() ?? 'Queue error';

    if (isCancelled.value || _hasTransitionedToMatch) return;
    if (code == 'INELIGIBLE' ||
        code == 'ROOM_CLOSED' ||
        code == 'ALREADY_QUEUED' ||
        code == 'ACTIVE_MATCH' ||
        code == 'INVALID_MODE') {
      isCancelled.value = true;
      Get.back();
      Get.snackbar(
        'Basketball',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (code == 'EXPIRED' || error['expired'] == true) {
      _handleQueueTimeout();
    }
  }

  void _handleQueueTimeout() {
    if (isCancelled.value) return;
    unawaited(_cancelLobby());
    Get.back();
    Get.snackbar(
      'Queue Expired',
      'Matchmaking queue expired. No opponent found.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFF27B35),
      colorText: Colors.white,
    );
  }

  void onStartGame() {
    final currentMatchId = matchId.value;
    if (isStarting.value || !isRoomFull.value || currentMatchId == null) return;

    if (AppConfig.useMocks) {
      isStarting.value = true;
      _simulateMockCountdownAndMatch(currentMatchId);
    } else if (_socketService.isConnected.value) {
      isStarting.value = true;
      _socketService.startMatch(currentMatchId);
    }
  }

  void _simulateMockCountdownAndMatch(String currentMatchId) {
    final youId = currentUserId ?? 'mock-student-id';
    final oppNick = opponentNickname.value ?? 'Mili';
    final oppAvatar = opponentAvatarUrl.value ?? 'assets/images/avatar_02.png';

    _socketService.simulateMockMatch(
      mode: mode,
      currentUserId: youId,
      currentUserNickname: effectiveUserNickname,
      opponentNickname: oppNick,
      opponentAvatarUrl: oppAvatar,
    );
  }

  Future<void> _cancelLobby() async {
    isCancelled.value = true;
    _cleanupTimers();
    final id = matchId.value;
    if (_socketService.isConnected.value) {
      if (id != null && !await _socketService.leaveMatch(id)) {
        try {
          await _repository.leaveMatch(id);
        } catch (_) {}
      }
      _socketService.cancelQueue();
      return;
    }
    try {
      if (id != null) await _repository.leaveMatch(id);
      await _repository.cancelQueue();
    } catch (_) {
      // A disconnected queue also expires on the server.
    }
  }

  Future<void> onBackToLobby() async {
    if (isCancelled.value) return;
    await _cancelLobby();
    if (!isClosed) Get.back();
  }

  Future<void> onCancel() => onBackToLobby();

  Future<void> onExploreStories() async {
    if (isCancelled.value) return;
    await _cancelLobby();
    if (!isClosed) Get.offNamed(Routes.STORY_LIBRARY);
  }

  GameMatchSnapshot _build1v1Snapshot(String mId, DateTime? deadlineAt) {
    final youId = currentUserId ?? 'student-you';
    final oppId = opponentUserId.value ?? 'student-peer';

    return GameMatchSnapshot(
      matchId: mId,
      mode: mode,
      phase: 'COUNTDOWN',
      deadlineAt: deadlineAt ?? DateTime.now().add(const Duration(seconds: 3)),
      serverNow: DateTime.now(),
      teams: [
        GameMatchTeam(
          id: 'team-1',
          label: 'Team A',
          members: [
            GameMatchParticipant(
              id: 'part-you-1',
              userId: youId,
              nickname: effectiveUserNickname,
              avatarUrl: effectiveUserAvatar,
              heroId: selectedHero?.displayName ?? 'Faith',
              jerseyNumber: 1,
              isConnected: true,
              isBot: false,
            ),
          ],
        ),
        GameMatchTeam(
          id: 'team-2',
          label: 'Team B',
          members: [
            GameMatchParticipant(
              id: 'part-opponent-2',
              userId: oppId,
              nickname: opponentNickname.value ?? 'Mili',
              avatarUrl: opponentAvatarUrl.value ?? 'assets/images/avatar_02.png',
              heroId: 'Faith',
              jerseyNumber: 2,
              isConnected: true,
              isBot: false,
            ),
          ],
        ),
      ],
      you: GameMatchYou(
        participantId: 'part-you-1',
        heroId: selectedHero?.displayName ?? 'Faith',
        jerseyNumber: 1,
      ),
    );
  }

  void _cleanupTimers() {
    _findingTimer?.cancel();
    _findingTimer = null;
    _queueExpiryTimer?.cancel();
    _queueExpiryTimer = null;
    _mockPeerTimer?.cancel();
    _mockPeerTimer = null;
  }

  @override
  void onClose() {
    _cleanupTimers();
    _connectionWorker?.dispose();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    if (!isCancelled.value && !_hasTransitionedToMatch) {
      unawaited(_cancelLobby());
    }
    super.onClose();
  }
}
