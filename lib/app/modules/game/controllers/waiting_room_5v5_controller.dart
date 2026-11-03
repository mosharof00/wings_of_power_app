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

class WaitingRoomSeat {
  final String? userId;
  final String nickname;
  final String? avatarUrl;
  final bool isLocal;
  final bool isOccupied;

  const WaitingRoomSeat({
    this.userId,
    required this.nickname,
    this.avatarUrl,
    this.isLocal = false,
    this.isOccupied = true,
  });

  const WaitingRoomSeat.empty()
      : userId = null,
        nickname = 'Waiti...',
        avatarUrl = null,
        isLocal = false,
        isOccupied = false;
}

class WaitingRoom5v5Controller extends GetxController {
  WaitingRoom5v5Controller({
    this.currentUserId,
    this.currentUserNickname,
    this.currentUserAvatar,
    this.selectedHero,
    this.initialTicketId,
    IGameRepository? repository,
    GameSocketService? socketService,
    this.mockPeerDelay = const Duration(seconds: 2),
    this.autoSimulateFill = true,
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
  final bool autoSimulateFill;
  final Duration findingTimeout;
  final Duration queueTimeout;

  final ticketId = RxnString();
  final matchId = RxnString();

  final filledCount = 1.obs;
  final isRoomFull = false.obs;
  final isPartial = false.obs;
  final isStarting = false.obs;
  final isCancelled = false.obs;

  final statusTitle = 'Finding your classmates...'.obs;
  final statusSubtitle = '[1 out of 10] is here'.obs;

  final teamASeats = <WaitingRoomSeat>[].obs;
  final teamBSeats = <WaitingRoomSeat>[].obs;

  bool _hasTransitionedToMatch = false;
  bool _isFindingTimedOut = false;
  final List<StreamSubscription> _subscriptions = [];
  Timer? _findingTimer;
  Timer? _queueExpiryTimer;
  Timer? _mockFillTimer;

  String get effectiveUserNickname =>
      (currentUserNickname != null && currentUserNickname!.isNotEmpty)
          ? currentUserNickname!
          : 'You';

  String get effectiveUserAvatar =>
      (currentUserAvatar != null && currentUserAvatar!.isNotEmpty)
          ? currentUserAvatar!
          : 'assets/images/avatar_01.png';

  @override
  void onInit() {
    super.onInit();
    ticketId.value = initialTicketId;
    _initSeats();
    _setupListeners();
    _startFindingTimer();
    _startQueueExpiryTimer();
    _initQueue();
  }

  void _initSeats() {
    teamASeats.assignAll([
      WaitingRoomSeat(
        userId: currentUserId,
        nickname: effectiveUserNickname,
        avatarUrl: effectiveUserAvatar,
        isLocal: true,
        isOccupied: true,
      ),
      const WaitingRoomSeat.empty(),
      const WaitingRoomSeat.empty(),
      const WaitingRoomSeat.empty(),
      const WaitingRoomSeat.empty(),
    ]);

    teamBSeats.assignAll([
      const WaitingRoomSeat.empty(),
      const WaitingRoomSeat.empty(),
      const WaitingRoomSeat.empty(),
      const WaitingRoomSeat.empty(),
      const WaitingRoomSeat.empty(),
    ]);
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
    _socketService.joinQueue('FIVE_V_FIVE');

    // If initialTicketId was not provided, call joinQueue REST as well
    if (ticketId.value == null || ticketId.value!.isEmpty) {
      try {
        final resp = await _repository.joinQueue(mode: 'FIVE_V_FIVE');
        ticketId.value = resp.ticketId;
      } catch (e) {
        debugPrint('[WaitingRoom5v5Controller] joinQueue error: $e');
      }
    }

    // Check if mock mode is active
    if (AppConfig.useMocks && autoSimulateFill) {
      _startMockFillSimulation();
    }
  }

  void _startFindingTimer() {
    _findingTimer?.cancel();
    _findingTimer = Timer(findingTimeout, () {
      if (!isRoomFull.value && !isCancelled.value) {
        _isFindingTimedOut = true;
        final filled = filledCount.value;
        final others = filled > 0 ? filled - 1 : 0;
        if (others > 0) {
          isPartial.value = true;
          statusTitle.value = 'Only $others classmates were found';
          statusSubtitle.value = 'Wait for others to join';
        } else {
          statusTitle.value = 'Finding your classmates...';
          statusSubtitle.value = 'Wait for others to join';
        }
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

  void _handleQueueUpdate(GameQueueUpdate update) {
    if (isCancelled.value) return;
    if (update.mode != 'FIVE_V_FIVE') return;

    final filled = update.filled > 0 ? update.filled : (update.players.isNotEmpty ? update.players.length : 1);
    filledCount.value = filled;

    if (filled >= 10 || update.players.length >= 10) {
      _findingTimer?.cancel();
      isRoomFull.value = true;
      isPartial.value = false;
      statusTitle.value = 'All Classmates are found';
      statusSubtitle.value = '[10 out of 10] is here';
      _updateSeatsFromPlayers(update.players, count: 10);
    } else {
      isRoomFull.value = false;
      final others = update.others ?? (filled > 0 ? filled - 1 : 0);
      final markPartial = update.partial == true || (others > 0 && _isFindingTimedOut);

      if (markPartial && others > 0) {
        isPartial.value = true;
        statusTitle.value = 'Only $others classmates were found';
        statusSubtitle.value = 'Wait for others to join';
      } else {
        isPartial.value = false;
        statusTitle.value = 'Finding your classmates...';
        statusSubtitle.value = '[$filled out of 10] is here';
      }
      _updateSeatsFromPlayers(update.players, count: filled);
    }
  }

  void _updateSeatsFromPlayers(List<dynamic> players, {int? count}) {
    final effectiveCount = count ?? (players.isNotEmpty ? players.length : 1);

    final List<WaitingRoomSeat> occupiedList = [];

    // Local seat
    occupiedList.add(
      WaitingRoomSeat(
        userId: currentUserId,
        nickname: effectiveUserNickname,
        avatarUrl: effectiveUserAvatar,
        isLocal: true,
        isOccupied: true,
      ),
    );

    // Add other players from list
    if (players.isNotEmpty) {
      for (final p in players) {
        if (p is Map) {
          final uid = p['userId']?.toString() ?? p['user_id']?.toString();
          final nick = p['nickname']?.toString() ?? 'Classmate';
          final avatar = p['avatarUrl']?.toString() ?? p['avatar_url']?.toString();

          // Don't add local user twice
          if (uid != null && uid == currentUserId) continue;
          if (nick == effectiveUserNickname && (currentUserId == null || uid == null)) continue;

          occupiedList.add(
            WaitingRoomSeat(
              userId: uid,
              nickname: nick,
              avatarUrl: avatar,
              isLocal: false,
              isOccupied: true,
            ),
          );
        }
      }
    }

    // If count exceeds occupiedList length, pad with placeholder classmates
    while (occupiedList.length < effectiveCount && occupiedList.length < 10) {
      final idx = occupiedList.length + 1;
      occupiedList.add(
        WaitingRoomSeat(
          userId: 'queue-player-$idx',
          nickname: _defaultNicknameForIndex(idx),
          avatarUrl: 'assets/images/avatar_0${(idx % 8) + 1}.png',
          isLocal: false,
          isOccupied: true,
        ),
      );
    }

    // Assign to Team A (slots 0..4) and Team B (slots 5..9)
    final newTeamA = <WaitingRoomSeat>[];
    for (int i = 0; i < 5; i++) {
      if (i < occupiedList.length) {
        newTeamA.add(occupiedList[i]);
      } else {
        newTeamA.add(const WaitingRoomSeat.empty());
      }
    }
    teamASeats.assignAll(newTeamA);

    final newTeamB = <WaitingRoomSeat>[];
    for (int i = 0; i < 5; i++) {
      final playerIndex = 5 + i;
      if (playerIndex < occupiedList.length) {
        newTeamB.add(occupiedList[playerIndex]);
      } else {
        newTeamB.add(const WaitingRoomSeat.empty());
      }
    }
    teamBSeats.assignAll(newTeamB);
  }

  void _handleMatchFound(GameMatchSnapshot snapshot) {
    if (isCancelled.value) return;
    _findingTimer?.cancel();
    matchId.value = snapshot.matchId;
    isRoomFull.value = true;
    isPartial.value = false;
    filledCount.value = 10;
    statusTitle.value = 'All Classmates are found';
    statusSubtitle.value = '[10 out of 10] is here';

    _updateSeatsFromSnapshot(snapshot);
  }

  void _updateSeatsFromSnapshot(GameMatchSnapshot snapshot) {
    if (snapshot.teams.isEmpty) return;

    final teamA = snapshot.teams.firstWhereOrNull((t) =>
            t.label.toUpperCase().contains('A') || t.id.contains('1')) ??
        snapshot.teams.first;
    final teamB = snapshot.teams.firstWhereOrNull((t) =>
            t.label.toUpperCase().contains('B') || t.id.contains('2')) ??
        (snapshot.teams.length > 1 ? snapshot.teams[1] : snapshot.teams.first);

    final newTeamA = <WaitingRoomSeat>[];
    for (int i = 0; i < 5; i++) {
      if (i < teamA.members.length) {
        final m = teamA.members[i];
        final isLocal = (m.userId != null && m.userId == currentUserId) ||
            (m.nickname == effectiveUserNickname && !m.isBot);
        newTeamA.add(
          WaitingRoomSeat(
            userId: m.userId,
            nickname: m.nickname ?? 'Classmate',
            avatarUrl: m.avatarUrl,
            isLocal: isLocal,
            isOccupied: true,
          ),
        );
      } else {
        newTeamA.add(const WaitingRoomSeat.empty());
      }
    }
    teamASeats.assignAll(newTeamA);

    final newTeamB = <WaitingRoomSeat>[];
    for (int i = 0; i < 5; i++) {
      if (i < teamB.members.length) {
        final m = teamB.members[i];
        final isLocal = (m.userId != null && m.userId == currentUserId) ||
            (m.nickname == effectiveUserNickname && !m.isBot);
        newTeamB.add(
          WaitingRoomSeat(
            userId: m.userId,
            nickname: m.nickname ?? 'Classmate',
            avatarUrl: m.avatarUrl,
            isLocal: isLocal,
            isOccupied: true,
          ),
        );
      } else {
        newTeamB.add(const WaitingRoomSeat.empty());
      }
    }
    teamBSeats.assignAll(newTeamB);
  }

  void _handleCountdown(GameCountdownEvent event) {
    if (isCancelled.value || _hasTransitionedToMatch) return;
    _hasTransitionedToMatch = true;
    _cleanupTimers();

    GameMatchSnapshot? snapshot = _socketService.latestMatch.value;
    if (snapshot == null || snapshot.teams.isEmpty) {
      snapshot = _build5v5Snapshot(event.matchId, event.deadlineAt);
    } else {
      snapshot = GameMatchSnapshot(
        matchId: snapshot.matchId,
        mode: 'FIVE_V_FIVE',
        phase: 'COUNTDOWN',
        deadlineAt: event.deadlineAt ??
            DateTime.now().add(Duration(seconds: event.value)),
        serverNow: DateTime.now(),
        teams: snapshot.teams,
        roundType: snapshot.roundType,
        roundId: snapshot.roundId,
        you: snapshot.you?.copyWith(canPass: true) ??
            const GameMatchYou(
              participantId: 'part-you-1',
              canBuzz: true,
              canPass: true,
            ),
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
      'Matchmaking queue expired. Not enough classmates found.',
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
        'match-5v5-${DateTime.now().millisecondsSinceEpoch}';

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
    _socketService.simulateMockMatch(
      mode: 'FIVE_V_FIVE',
      currentUserId: youId,
      currentUserNickname: effectiveUserNickname,
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

  GameMatchSnapshot _build5v5Snapshot(String mId, DateTime? deadlineAt) {
    final youId = currentUserId ?? 'student-you';

    final teamAMembers = <GameMatchParticipant>[];
    for (int i = 0; i < teamASeats.length; i++) {
      final s = teamASeats[i];
      if (s.isOccupied) {
        teamAMembers.add(
          GameMatchParticipant(
            id: s.isLocal ? 'part-you-1' : 'part-teama-${i + 1}',
            userId: s.userId ?? (s.isLocal ? youId : 'student-teama-${i + 1}'),
            nickname: s.nickname,
            avatarUrl: s.avatarUrl ?? 'assets/images/avatar_01.png',
            heroId: s.isLocal ? (selectedHero?.displayName ?? 'Faith') : 'Harold',
            jerseyNumber: i + 1,
            isConnected: true,
            isBot: false,
          ),
        );
      }
    }

    final teamBMembers = <GameMatchParticipant>[];
    for (int i = 0; i < teamBSeats.length; i++) {
      final s = teamBSeats[i];
      if (s.isOccupied) {
        teamBMembers.add(
          GameMatchParticipant(
            id: s.isLocal ? 'part-you-1' : 'part-teamb-${i + 6}',
            userId: s.userId ?? (s.isLocal ? youId : 'student-teamb-${i + 6}'),
            nickname: s.nickname,
            avatarUrl: s.avatarUrl ?? 'assets/images/avatar_02.png',
            heroId: s.isLocal ? (selectedHero?.displayName ?? 'Faith') : 'Faith',
            jerseyNumber: i + 6,
            isConnected: true,
            isBot: false,
          ),
        );
      }
    }

    return GameMatchSnapshot(
      matchId: mId,
      mode: 'FIVE_V_FIVE',
      phase: 'COUNTDOWN',
      deadlineAt: deadlineAt ?? DateTime.now().add(const Duration(seconds: 3)),
      serverNow: DateTime.now(),
      teams: [
        GameMatchTeam(
          id: 'team-a',
          label: 'Team A',
          members: teamAMembers,
        ),
        GameMatchTeam(
          id: 'team-b',
          label: 'Team B',
          members: teamBMembers,
        ),
      ],
      you: GameMatchYou(
        participantId: 'part-you-1',
        heroId: selectedHero?.displayName ?? 'Faith',
        jerseyNumber: 1,
        canPass: true,
        canBuzz: true,
      ),
    );
  }

  // --- Offline / Mock simulation support ---

  void simulateFillStep({
    required int filled,
    bool markPartial = false,
    List<Map<String, dynamic>>? customPlayers,
  }) {
    if (isCancelled.value) return;
    filledCount.value = filled;

    final mockPlayers = customPlayers ?? _generateMockPlayers(filled);

    if (filled >= 10) {
      _findingTimer?.cancel();
      isRoomFull.value = true;
      isPartial.value = false;
      statusTitle.value = 'All Classmates are found';
      statusSubtitle.value = '[10 out of 10] is here';
      _updateSeatsFromPlayers(mockPlayers, count: 10);
      matchId.value ??= 'match-5v5-${DateTime.now().millisecondsSinceEpoch}';

      final snapshot = _build5v5Snapshot(
        matchId.value!,
        DateTime.now().add(const Duration(seconds: 3)),
      );
      _socketService.latestMatch.value = snapshot;
    } else {
      isRoomFull.value = false;
      final others = filled > 0 ? filled - 1 : 0;
      if (markPartial && others > 0) {
        isPartial.value = true;
        statusTitle.value = 'Only $others classmates were found';
        statusSubtitle.value = 'Wait for others to join';
      } else {
        isPartial.value = false;
        statusTitle.value = 'Finding your classmates...';
        statusSubtitle.value = '[$filled out of 10] is here';
      }
      _updateSeatsFromPlayers(mockPlayers, count: filled);
    }
  }

  void _startMockFillSimulation() {
    _mockFillTimer?.cancel();
    _mockFillTimer = Timer(mockPeerDelay, () {
      if (isCancelled.value || isRoomFull.value) return;
      // Step 1: 2/10
      simulateFillStep(filled: 2);

      // Step 2: 4/10 after 1.5s
      _mockFillTimer = Timer(const Duration(milliseconds: 1500), () {
        if (isCancelled.value || isRoomFull.value) return;
        simulateFillStep(filled: 4);

        // Step 3: partial state after 1.5s
        _mockFillTimer = Timer(const Duration(milliseconds: 1500), () {
          if (isCancelled.value || isRoomFull.value) return;
          simulateFillStep(filled: 4, markPartial: true);

          // Step 4: 10/10 ready after 2s
          _mockFillTimer = Timer(const Duration(milliseconds: 2000), () {
            if (isCancelled.value || isRoomFull.value) return;
            simulateFillStep(filled: 10);
          });
        });
      });
    });
  }

  List<Map<String, dynamic>> _generateMockPlayers(int count) {
    const defaultRoster = [
      {'nickname': 'Mili', 'avatarUrl': 'assets/images/avatar_02.png'},
      {'nickname': 'Ethen', 'avatarUrl': 'assets/images/avatar_03.png'},
      {'nickname': 'Frank', 'avatarUrl': 'assets/images/avatar_04.png'},
      {'nickname': 'Lui', 'avatarUrl': 'assets/images/avatar_05.png'},
      {'nickname': 'Maya', 'avatarUrl': 'assets/images/avatar_06.png'},
      {'nickname': 'Jordan', 'avatarUrl': 'assets/images/avatar_07.png'},
      {'nickname': 'Sam', 'avatarUrl': 'assets/images/avatar_08.png'},
      {'nickname': 'Chloe', 'avatarUrl': 'assets/images/avatar_01.png'},
      {'nickname': 'Lucas', 'avatarUrl': 'assets/images/avatar_02.png'},
    ];

    final result = <Map<String, dynamic>>[];
    for (int i = 0; i < count - 1 && i < defaultRoster.length; i++) {
      result.add({
        'userId': 'mock-student-${i + 2}',
        'nickname': defaultRoster[i]['nickname'],
        'avatarUrl': defaultRoster[i]['avatarUrl'],
      });
    }
    return result;
  }

  String _defaultNicknameForIndex(int idx) {
    const names = [
      'Mili',
      'Ethen',
      'Frank',
      'Lui',
      'Maya',
      'Jordan',
      'Sam',
      'Chloe',
      'Lucas',
      'Leo',
    ];
    if (idx >= 1 && idx <= names.length) {
      return names[idx - 1];
    }
    return 'Classmate $idx';
  }

  void _cleanupTimers() {
    _findingTimer?.cancel();
    _findingTimer = null;
    _queueExpiryTimer?.cancel();
    _queueExpiryTimer = null;
    _mockFillTimer?.cancel();
    _mockFillTimer = null;
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

