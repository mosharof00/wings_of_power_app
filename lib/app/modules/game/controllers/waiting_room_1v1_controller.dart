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
    _subscriptions.add(_socketService.onQueueError.listen(_handleQueueError));
  }

  Future<void> _initQueue() async {
    try {
      await _socketService.connect();
    } catch (_) {}

    // Send queue:join over socket
    _socketService.joinQueue('ONE_V_ONE');

    // If initialTicketId was not provided, call joinQueue REST as well
    if (ticketId.value == null || ticketId.value!.isEmpty) {
      try {
        final resp = await _repository.joinQueue(mode: 'ONE_V_ONE');
        ticketId.value = resp.ticketId;
      } catch (e) {
        debugPrint('[WaitingRoom1v1Controller] joinQueue error: $e');
      }
    }

    // Check if mock mode is active
    if (AppConfig.useMocks && autoSimulatePeer) {
      _startMockPeerSimulation();
    }
  }

  void _startFindingTimer() {
    _findingTimer?.cancel();
    _findingTimer = Timer(findingTimeout, () {
      if (!isRoomFull.value && !isCancelled.value) {
        statusTitle.value = 'No one is found';
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
    if (update.mode != 'ONE_V_ONE') return;

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
    if (isCancelled.value) return;
    _findingTimer?.cancel();
    matchId.value = snapshot.matchId;

    // Find peer from teams
    final myId = currentUserId ?? '';
    for (final team in snapshot.teams) {
      for (final member in team.members) {
        if (member.userId != myId && !member.isBot) {
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
    statusSubtitle.value = 'Click below to start the game';
  }

  void _handleCountdown(GameCountdownEvent event) {
    if (isCancelled.value || _hasTransitionedToMatch) return;
    _hasTransitionedToMatch = true;
    _cleanupTimers();

    GameMatchSnapshot? snapshot = _socketService.latestMatch.value;
    if (snapshot == null || snapshot.teams.isEmpty) {
      snapshot = _build1v1Snapshot(event.matchId, event.deadlineAt);
    } else {
      snapshot = GameMatchSnapshot(
        matchId: snapshot.matchId,
        mode: 'ONE_V_ONE',
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

    Get.off(
      () => GameMatchHoldView(
        snapshot: snapshot!,
        currentUserId: currentUserId,
        currentUserNickname: currentUserNickname,
      ),
      routeName: '/game/match',
    );
  }

  void _handleQueueError(Map<String, dynamic> error) {
    final code = error['code']?.toString() ?? '';
    final message = error['message']?.toString() ?? 'Queue error';

    if (code == 'ALREADY_QUEUED') {
      // Benign warning if joined via REST then socket
      return;
    }

    if (code == 'INELIGIBLE') {
      Get.back();
      Get.snackbar(
        'Not Eligible',
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
    isCancelled.value = true;
    _cleanupTimers();
    _socketService.cancelQueue();
    _repository.cancelQueue().catchError((_) {});
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
    if (isStarting.value || (!_hasTransitionedToMatch && !isRoomFull.value)) {
      return;
    }
    isStarting.value = true;

    final currentMatchId = matchId.value ??
        _socketService.latestMatch.value?.matchId ??
        'match-1v1-${DateTime.now().millisecondsSinceEpoch}';

    matchId.value = currentMatchId;
    _socketService.startMatch(currentMatchId);

    if (AppConfig.useMocks ||
        _socketService.socket == null ||
        !_socketService.isConnected.value) {
      _simulateMockCountdownAndMatch(currentMatchId);
    }
  }

  void _simulateMockCountdownAndMatch(String currentMatchId) {
    final youId = currentUserId ?? 'mock-student-id';
    final oppNick = opponentNickname.value ?? 'Mili';
    final oppAvatar = opponentAvatarUrl.value ?? 'assets/images/avatar_02.png';

    _socketService.simulateMockMatch(
      mode: 'ONE_V_ONE',
      currentUserId: youId,
      currentUserNickname: effectiveUserNickname,
      opponentNickname: oppNick,
      opponentAvatarUrl: oppAvatar,
    );
  }

  Future<void> onBackToLobby() async {
    isCancelled.value = true;
    _cleanupTimers();
    _socketService.cancelQueue();
    try {
      await _repository.cancelQueue();
    } catch (_) {}
    Get.back();
  }

  Future<void> onCancel() async {
    isCancelled.value = true;
    _cleanupTimers();
    final mId = matchId.value;
    if (mId != null && mId.isNotEmpty) {
      _socketService.leaveMatch(mId);
      try {
        await _repository.leaveMatch(mId);
      } catch (_) {}
    }
    _socketService.cancelQueue();
    try {
      await _repository.cancelQueue();
    } catch (_) {}
    Get.back();
  }

  Future<void> onExploreStories() async {
    isCancelled.value = true;
    _cleanupTimers();
    _socketService.cancelQueue();
    try {
      await _repository.cancelQueue();
    } catch (_) {}
    Get.offNamed(Routes.STORY_LIBRARY);
  }

  GameMatchSnapshot _build1v1Snapshot(String mId, DateTime? deadlineAt) {
    final youId = currentUserId ?? 'student-you';
    final oppId = opponentUserId.value ?? 'student-peer';

    return GameMatchSnapshot(
      matchId: mId,
      mode: 'ONE_V_ONE',
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
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    if (!isStarting.value && !_hasTransitionedToMatch) {
      _socketService.cancelQueue();
      _repository.cancelQueue().catchError((_) {});
    }
    super.onClose();
  }
}
