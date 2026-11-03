import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/models/game_match.dart';
import 'package:wings_of_power_app/app/data/repositories/igame_repository.dart';
import 'package:wings_of_power_app/app/data/services/game_socket_service.dart';

class GameMatchHoldView extends StatefulWidget {
  const GameMatchHoldView({
    super.key,
    required this.snapshot,
    this.currentUserId,
    this.currentUserNickname,
  });

  final GameMatchSnapshot snapshot;
  final String? currentUserId;
  final String? currentUserNickname;

  @override
  State<GameMatchHoldView> createState() => _GameMatchHoldViewState();
}

class _GameMatchHoldViewState extends State<GameMatchHoldView> {
  late GameMatchSnapshot _snapshot;
  StreamSubscription? _matchSub;
  StreamSubscription? _snapshotSub;
  Timer? _countdownTimer;
  int _secondsLeft = 0;

  GameSocketService? get _socketService =>
      Get.isRegistered<GameSocketService>()
          ? Get.find<GameSocketService>()
          : null;

  IGameRepository? get _repository =>
      Get.isRegistered<IGameRepository>() ? Get.find<IGameRepository>() : null;

  @override
  void initState() {
    super.initState();
    _snapshot = widget.snapshot;
    _computeSecondsLeft();
    _startTimer();

    final service = _socketService;
    if (service != null) {
      _matchSub = service.onMatchFound.listen((s) {
        if (mounted) {
          setState(() {
            _snapshot = s;
            _computeSecondsLeft();
          });
        }
      });
      _snapshotSub = service.onSnapshot.listen((s) {
        if (mounted) {
          setState(() {
            _snapshot = s;
            _computeSecondsLeft();
          });
        }
      });
    }
  }

  void _computeSecondsLeft() {
    final deadline = _snapshot.deadlineAt;
    if (deadline != null) {
      final diff = deadline.difference(DateTime.now()).inSeconds;
      _secondsLeft = diff > 0 ? diff : 0;
    } else {
      _secondsLeft = 3;
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          if (_secondsLeft > 0) {
            _secondsLeft--;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _matchSub?.cancel();
    _snapshotSub?.cancel();
    super.dispose();
  }

  Future<void> _handleLeave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Match?'),
        content: const Text(
          'Are you sure you want to leave this practice match?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE86726),
            ),
            child: const Text(
              'Leave',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (_snapshot.matchId.isNotEmpty) {
          _socketService?.leaveMatch(_snapshot.matchId);
          await _repository?.leaveMatch(_snapshot.matchId);
        }
      } catch (_) {}
      _socketService?.disconnect();
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final you = _findYouParticipant();
    final opponent = _findOpponentParticipant(you);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7822B7),
              Color(0xFF5D1D9B),
              Color(0xFF4C157E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 12.h),
              // Top Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _handleLeave,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4C1D95),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFFFFD54F),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.sports_basketball,
                            color: const Color(0xFFFFD54F),
                            size: 16.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'PRACTICE ARENA',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(width: 40.w),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Match Ready Title
              Text(
                'Match Ready',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFFD54F),
                  shadows: const [
                    Shadow(
                      color: Color(0xFF3B0764),
                      offset: Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Mode: ${_snapshot.mode}  •  Phase: ${_snapshot.phase}',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 12.h),

              // Countdown Chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE86726),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x44E86726),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Starting in ${_secondsLeft}s',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Matchup Area (You vs Opponent)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      // YOU Card
                      Expanded(
                        child: _ParticipantCard(
                          isYou: true,
                          participant: you,
                          fallbackNickname: widget.currentUserNickname ?? 'Alex',
                          fallbackHero: 'Faith',
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // VS divider
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFD54F),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              'VS',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1E1B4B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 12.w),
                      // OPPONENT Card
                      Expanded(
                        child: _ParticipantCard(
                          isYou: false,
                          participant: opponent,
                          fallbackNickname: 'Practice Bot',
                          fallbackHero: 'Harold',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Match Details & Status
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(() {
                            final connected =
                                _socketService?.isConnected.value ?? false;
                            return Container(
                              width: 10.w,
                              height: 10.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: connected
                                    ? const Color(0xFF4ADE80)
                                    : const Color(0xFFF87171),
                              ),
                            );
                          }),
                          SizedBox(width: 8.w),
                          Obx(() {
                            final connected =
                                _socketService?.isConnected.value ?? false;
                            return Text(
                              connected
                                  ? 'Connected to live match socket'
                                  : 'Reconnecting to match gateway...',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Match ID: ${_snapshot.matchId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Leave Match Action Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _handleLeave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        side: const BorderSide(color: Colors.white38),
                      ),
                    ),
                    child: Text(
                      'Leave Match',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  GameMatchParticipant _findYouParticipant() {
    final youId = widget.currentUserId;
    final youFromList =
        _snapshot.allParticipants.firstWhereOrNull((p) => p.userId == youId);
    if (youFromList != null) return youFromList;

    final firstNonBot =
        _snapshot.allParticipants.firstWhereOrNull((p) => !p.isBot);
    if (firstNonBot != null) return firstNonBot;

    return GameMatchParticipant(
      userId: youId ?? 'you',
      nickname: widget.currentUserNickname ?? 'Alex',
      avatarUrl: 'assets/images/avatar_01.png',
      jerseyNumber: _snapshot.you?.jerseyNumber ?? 1,
      isBot: false,
    );
  }

  GameMatchParticipant _findOpponentParticipant(GameMatchParticipant you) {
    return _snapshot.botOrOpponent(you.userId);
  }
}

class _ParticipantCard extends StatelessWidget {
  const _ParticipantCard({
    required this.isYou,
    required this.participant,
    required this.fallbackNickname,
    required this.fallbackHero,
  });

  final bool isYou;
  final GameMatchParticipant participant;
  final String fallbackNickname;
  final String fallbackHero;

  @override
  Widget build(BuildContext context) {
    final nickname = participant.nickname ?? fallbackNickname;
    final isBot = participant.isBot;
    final jersey = participant.jerseyNumber ?? (isYou ? 1 : 2);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isYou
            ? Colors.white
            : const Color(0xFFFFF6EB),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: isYou ? const Color(0xFFFFD54F) : const Color(0xFFFFDFC8),
          width: 2.w,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tag: YOU or OPPONENT
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: isYou ? const Color(0xFFE86726) : const Color(0xFF6B7280),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              isYou ? 'YOU' : (isBot ? 'BOT' : 'OPPONENT'),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Avatar Image
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isYou ? const Color(0xFFFFA726) : const Color(0xFFD1D5DB),
                width: 2.5.w,
              ),
            ),
            child: ClipOval(
              child: isBot
                  ? Container(
                      color: const Color(0xFFE5E7EB),
                      child: Icon(
                        Icons.smart_toy_rounded,
                        size: 38.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    )
                  : Image.asset(
                      participant.avatarUrl ?? 'assets/images/avatar_01.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person,
                        size: 36,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
            ),
          ),
          SizedBox(height: 10.h),

          // Nickname
          Text(
            nickname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          SizedBox(height: 4.h),

          // Jersey Number Chip
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'Jersey #$jersey',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
          SizedBox(height: 8.h),

          // Hero Info or Status
          Text(
            participant.heroId != null
                ? 'Hero: ${participant.heroId}'
                : (isBot ? 'Bot Seat' : 'Power Ready'),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFE86726),
            ),
          ),
        ],
      ),
    );
  }
}
