import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/data/models/game_match.dart';
import 'package:wings_of_power_app/app/modules/game/controllers/game_play_controller.dart';
import 'single_shot_court_view.dart';

class ChampionshipCourtView extends StatefulWidget {
  const ChampionshipCourtView({
    super.key,
    required this.controller,
  });

  final GamePlayController controller;

  @override
  State<ChampionshipCourtView> createState() => _ChampionshipCourtViewState();
}

class _ChampionshipCourtViewState extends State<ChampionshipCourtView>
    with SingleTickerProviderStateMixin {
  late AnimationController _shotAnimController;
  late Animation<double> _flightProgress;

  Offset _dragStart = Offset.zero;
  Offset _currentDrag = Offset.zero;
  bool _isDragging = false;
  bool _isShotInFlight = false;
  bool? _shotMade;

  Offset _shotStartOffset = Offset.zero;
  Offset _shotTargetOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _shotAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _flightProgress = CurvedAnimation(
      parent: _shotAnimController,
      curve: Curves.easeOutCubic,
    );

    _shotAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_shotMade != null) {
          widget.controller.onSwipeShoot(made: _shotMade!);
        }
      }
    });
  }

  @override
  void dispose() {
    _shotAnimController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.controller.isShooter) return;
    if (widget.controller.hasSwiped.value || _isShotInFlight) return;

    setState(() {
      _dragStart = details.localPosition;
      _currentDrag = details.localPosition;
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _currentDrag = details.localPosition;
    });
  }

  void _onPanEnd(DragEndDetails details, Size screenSize) {
    if (!_isDragging) return;
    _isDragging = false;

    final dy = details.velocity.pixelsPerSecond.dy;
    final dx = details.velocity.pixelsPerSecond.dx;
    final dragDelta = _currentDrag - _dragStart;

    final isUpwardSwipe = dy < -220 || dragDelta.dy < -60;

    if (!isUpwardSwipe) {
      setState(() {});
      return;
    }

    final hoopX = screenSize.width / 2;
    final hoopY = screenSize.height * 0.32;

    final swipeEndX = _currentDrag.dx;
    final swipeDiffFromCenter = (swipeEndX - hoopX).abs();
    final horizontalTolerance = screenSize.width * 0.35;

    final made = swipeDiffFromCenter < horizontalTolerance && (dx.abs() < 1200);

    _startShotFlight(
      start: Offset(screenSize.width / 2, screenSize.height * 0.76),
      target: Offset(
        made ? hoopX : (hoopX + (dx >= 0 ? 50.w : -50.w)),
        made ? hoopY : (hoopY + 18.h),
      ),
      made: made,
    );
  }

  void _startShotFlight({
    required Offset start,
    required Offset target,
    required bool made,
  }) {
    setState(() {
      _isShotInFlight = true;
      _shotMade = made;
      _shotStartOffset = start;
      _shotTargetOffset = target;
    });
    _shotAnimController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isShooter = widget.controller.isShooter;
    final shootoutStart = widget.controller.shootoutStart.value;
    final shooterName = shootoutStart?.shooterName ?? 'Shooter';
    final shooterTeam = widget.controller.shooterTeamLabel;
    final result = widget.controller.shootoutResult.value;

    final teams = widget.controller.snapshot.value.teams;
    final teamA = teams.isNotEmpty ? teams[0] : null;
    final teamB = teams.length > 1 ? teams[1] : null;

    final teamAXp = widget.controller.getTeamScore(0);
    final teamBXp = widget.controller.getTeamScore(1);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1B0736),
            Color(0xFF330C66),
            Color(0xFF4C157E),
          ],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // 1. Basketball Court Floor
            Positioned.fill(
              child: CustomPaint(
                painter: CourtBackgroundPainter(),
              ),
            ),

            // 2. Basketball Hoop
            Positioned(
              top: screenSize.height * 0.20,
              left: 0,
              right: 0,
              child: const Center(
                child: BasketballHoopWidget(),
              ),
            ),

            // 3. Team Lineups along left and right court boundaries
            Positioned(
              left: 8.w,
              top: screenSize.height * 0.22,
              bottom: screenSize.height * 0.16,
              child: _buildTeamLineupColumn(
                team: teamA,
                isLeft: true,
                baseXp: teamAXp,
              ),
            ),
            Positioned(
              right: 8.w,
              top: screenSize.height * 0.22,
              bottom: screenSize.height * 0.16,
              child: _buildTeamLineupColumn(
                team: teamB,
                isLeft: false,
                baseXp: teamBXp,
              ),
            ),

            // 4. Basketball
            _buildBasketball(screenSize, isShooter),

            // 5. "Swipe to Shoot!" or Opponent Waiting Banner
            if (result == null && !_isShotInFlight)
              Positioned(
                bottom: 40.h,
                left: 20.w,
                right: 20.w,
                child: Center(
                  child: isShooter
                      ? const SwipePromptBanner()
                      : OpponentWaitingBanner(shooterName: shooterName),
                ),
              ),

            // 6. Championship Shootout Result Overlay
            if (result != null)
              Positioned.fill(
                child: _ChampionshipResultOverlay(
                  result: result,
                  shooterTeam: shooterTeam,
                ),
              ),

            // 7. Top Navigation & Score Header Bar
            Positioned(
              top: 8.h,
              left: 16.w,
              right: 16.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Close button
                      GestureDetector(
                        onTap: () => widget.controller.onLeaveTap(context),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE86726),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                        ),
                      ),
                      // Round 4 Wings Final Title
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Round 4',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFD54F),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Wings Final',
                              style: TextStyle(
                                fontSize: 19.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Power bolt button
                      GestureDetector(
                        onTap: () => widget.controller.onPowersTap(context),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE86726),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.bolt_rounded,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Championship Score & 00:60 Timer Bar (matching championship_team_lineup.png)
                  _buildChampionshipScoreBar(
                    teamALabel: widget.controller.getTeamLabel(0),
                    teamAXp: teamAXp,
                    teamBLabel: widget.controller.getTeamLabel(1),
                    teamBXp: teamBXp,
                    timerString: widget.controller.timerString.value,
                  ),
                ],
              ),
            ),

            // 8. Swipe Gesture Detector
            if (isShooter &&
                !widget.controller.hasSwiped.value &&
                !_isShotInFlight &&
                result == null)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: (details) => _onPanEnd(details, screenSize),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChampionshipScoreBar({
    required String teamALabel,
    required int teamAXp,
    required String teamBLabel,
    required int teamBXp,
    required String timerString,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Team A
          Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE86726),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    teamALabel,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$teamAXp XP',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFFD54F),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 00:60 Center Timer Pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 15.sp,
                  color: const Color(0xFFB45309),
                ),
                SizedBox(width: 4.w),
                Text(
                  timerString,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),

          // Team B
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    teamBLabel,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$teamBXp XP',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFFD54F),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 6.w),
              Container(
                width: 10.w,
                height: 10.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF8B5CF6),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLineupColumn({
    required GameMatchTeam? team,
    required bool isLeft,
    required int baseXp,
  }) {
    final members = team?.members ?? const <GameMatchParticipant>[];
    // Art displays 5 roster slots along each side with per-player XP tags (e.g. 2XP, 4XP, 2XP, 8XP, 6XP)
    final count = members.isNotEmpty ? members.length.clamp(1, 5) : 5;
    const defaultXps = [2, 4, 2, 8, 6];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(count, (index) {
        final member = index < members.length ? members[index] : null;
        final avatar = member?.avatarUrl ?? 'assets/images/avatar_0${(index % 8) + 1}.png';
        final xpValue = defaultXps[index % defaultXps.length];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular Player Avatar
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLeft ? const Color(0xFFFFD54F) : const Color(0xFFC084FC),
                  width: 2.w,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x44000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  avatar,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.person,
                    size: 22,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            // Per-Player XP Tag Pill (e.g. "2XP", "4XP", "6XP", "8XP")
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B4B).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: const Color(0xFFFFD54F),
                  width: 1,
                ),
              ),
              child: Text(
                '${xpValue}XP',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFFD54F),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBasketball(Size screenSize, bool isShooter) {
    if (_isShotInFlight) {
      return AnimatedBuilder(
        animation: _flightProgress,
        builder: (context, child) {
          final t = _flightProgress.value;
          final currentX =
              _shotStartOffset.dx + (_shotTargetOffset.dx - _shotStartOffset.dx) * t;
          final linearY =
              _shotStartOffset.dy + (_shotTargetOffset.dy - _shotStartOffset.dy) * t;
          final archHeight = 90.h * math.sin(t * math.pi);
          final currentY = linearY - archHeight;

          final scale = 1.0 - (0.55 * t);

          return Positioned(
            left: currentX - (45.w * scale),
            top: currentY - (45.w * scale),
            child: Transform.scale(
              scale: scale,
              child: const BasketballWidget(size: 90),
            ),
          );
        },
      );
    }

    final baseOffset = _isDragging ? (_currentDrag - _dragStart) : Offset.zero;
    final clampedDragY = baseOffset.dy.clamp(-120.0, 0.0);
    final clampedDragX = baseOffset.dx.clamp(-40.0, 40.0);

    return Positioned(
      bottom: 100.h - clampedDragY,
      left: (screenSize.width / 2 - 45.w) + clampedDragX,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70.w,
            height: 14.h,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
          SizedBox(height: 4.h),
          const BasketballWidget(size: 90),
        ],
      ),
    );
  }
}

/// Championship Shootout Result Overlay matching championship_shootout.png
class _ChampionshipResultOverlay extends StatelessWidget {
  const _ChampionshipResultOverlay({
    required this.result,
    required this.shooterTeam,
  });

  final GameShootoutResultEvent result;
  final String shooterTeam;

  @override
  Widget build(BuildContext context) {
    final made = result.made;
    final xpEarned = result.xpEarned;

    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 32.w),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B4B),
            borderRadius: BorderRadius.circular(32.r),
            border: Border.all(
              color: made ? const Color(0xFFFFD54F) : const Color(0xFFEF4444),
              width: 2.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                made ? 'Congratulations' : 'Oops! So Close!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w900,
                  color: made ? const Color(0xFFFFD54F) : Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Basket Bonus',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                made ? '+$xpEarned XP' : '+0 XP',
                style: TextStyle(
                  fontSize: 38.sp,
                  fontWeight: FontWeight.w900,
                  color: made ? const Color(0xFF22C55E) : const Color(0xFFF87171),
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E1065),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFFFD54F), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Team Earned  ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      made ? '48XP' : '0XP',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFFD54F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
