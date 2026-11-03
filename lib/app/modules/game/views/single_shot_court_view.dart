import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/modules/game/controllers/game_play_controller.dart';
import 'package:wings_of_power_app/app/modules/game/views/widgets/game_vs_pills.dart';

class SingleShotCourtView extends StatefulWidget {
  const SingleShotCourtView({
    super.key,
    required this.controller,
  });

  final GamePlayController controller;

  @override
  State<SingleShotCourtView> createState() => _SingleShotCourtViewState();
}

class _SingleShotCourtViewState extends State<SingleShotCourtView>
    with SingleTickerProviderStateMixin {
  late AnimationController _shotAnimController;
  late Animation<double> _flightProgress;

  Offset _dragStart = Offset.zero;
  Offset _currentDrag = Offset.zero;
  bool _isDragging = false;
  bool _isShotInFlight = false;
  bool? _shotMade;

  // Ball flight trajectory parameters
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

    // Detect upward swipe: either high upward velocity or significant upward drag displacement
    final isUpwardSwipe = dy < -220 || dragDelta.dy < -60;

    if (!isUpwardSwipe) {
      setState(() {});
      return;
    }

    // Hoop target in relative screen coordinates (hoop center is horizontally centered, ~30% from top)
    final hoopX = screenSize.width / 2;
    final hoopY = screenSize.height * 0.32;

    // Calculate alignment towards hoop
    final swipeEndX = _currentDrag.dx;
    final swipeDiffFromCenter = (swipeEndX - hoopX).abs();
    final horizontalTolerance = screenSize.width * 0.35;

    // Made if swipe is reasonably aligned towards center hoop
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
    final shooterXp = widget.controller.shooterTeamXp;
    final result = widget.controller.shootoutResult.value;

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
            // 1. Basketball Court & Stadium Floor Background
            Positioned.fill(
              child: CustomPaint(
                painter: _CourtBackgroundPainter(),
              ),
            ),

            // 2. Basketball Hoop (Backboard, Rim, Net)
            Positioned(
              top: screenSize.height * 0.20,
              left: 0,
              right: 0,
              child: const Center(
                child: _BasketballHoopWidget(),
              ),
            ),

            // 3. Basketball (in flight or sitting on court)
            _buildBasketball(screenSize, isShooter),

            // 4. "Swipe to Shoot!" or Opponent Waiting Banner
            if (result == null && !_isShotInFlight)
              Positioned(
                bottom: 40.h,
                left: 20.w,
                right: 20.w,
                child: Center(
                  child: isShooter
                      ? _SwipePromptBanner()
                      : _OpponentWaitingBanner(shooterName: shooterName),
                ),
              ),

            // 5. Result Banner Overlay ("Basket Bonus +2XP" or "Oops! So Close! +0 XP")
            if (result != null)
              Positioned.fill(
                child: _ShootoutResultOverlay(result: result),
              ),

            // 6. Top Bar (Close 'x', Round Title, Power Bolt)
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
                      // Center Title
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.controller.currentRoundSubtitle,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFD54F),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              widget.controller.currentRoundTitle,
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

                  // Vs Pills with live scores (+3 on made shot)
                  Obx(
                    () => GameVsPills(
                      teamALabel: widget.controller.getTeamLabel(0),
                      teamAScore: widget.controller.getTeamScore(0),
                      teamBLabel: widget.controller.getTeamLabel(1),
                      teamBScore: widget.controller.getTeamScore(1),
                      isTeamAActive: shooterTeam.toLowerCase() == 'team a',
                      isTeamBActive: shooterTeam.toLowerCase() == 'team b',
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Shooter Opportunity Card
                  _buildShooterInfoCard(
                    shooterName: shooterName,
                    shooterTeam: shooterTeam,
                    teamXp: shooterXp,
                  ),
                ],
              ),
            ),

            // 7. Touch & Swipe gesture detector covering the shooting area
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

  Widget _buildShooterInfoCard({
    required String shooterName,
    required String shooterTeam,
    required int teamXp,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFFDE68A),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Shooter details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Shot opportunity earned!',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Shooter: $shooterName ($shooterTeam)',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ],
          ),

          // Right: Timer and XP Pill
          Row(
            children: [
              // 60s Countdown Timer Pill
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14.sp,
                        color: const Color(0xFFB45309),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        widget.controller.timerString.value,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // Team Score XP Pill
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Team Score',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(
                        Icons.sports_basketball,
                        size: 15.sp,
                        color: const Color(0xFFEA580C),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '$teamXp XP',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFEA580C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasketball(Size screenSize, bool isShooter) {
    if (_isShotInFlight) {
      return AnimatedBuilder(
        animation: _flightProgress,
        builder: (context, child) {
          final t = _flightProgress.value;
          // Parabolic trajectory: arch upward
          final currentX =
              _shotStartOffset.dx + (_shotTargetOffset.dx - _shotStartOffset.dx) * t;
          final linearY =
              _shotStartOffset.dy + (_shotTargetOffset.dy - _shotStartOffset.dy) * t;
          final archHeight = 90.h * math.sin(t * math.pi);
          final currentY = linearY - archHeight;

          // Scale down to simulate depth
          final scale = 1.0 - (0.55 * t);

          return Positioned(
            left: currentX - (45.w * scale),
            top: currentY - (45.w * scale),
            child: Transform.scale(
              scale: scale,
              child: const _BasketballWidget(size: 90),
            ),
          );
        },
      );
    }

    // Sitting on court at baseline
    final baseOffset = _isDragging ? (_currentDrag - _dragStart) : Offset.zero;
    final clampedDragY = baseOffset.dy.clamp(-120.0, 0.0);
    final clampedDragX = baseOffset.dx.clamp(-40.0, 40.0);

    return Positioned(
      bottom: 100.h - clampedDragY,
      left: (screenSize.width / 2 - 45.w) + clampedDragX,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Shadow on court floor
          Container(
            width: 70.w,
            height: 14.h,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
          SizedBox(height: 4.h),
          const _BasketballWidget(size: 90),
        ],
      ),
    );
  }
}

/// Dynamic Court Background Painter with hardwood planks & purple key
class _CourtBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Upper dark arena background
    final arenaPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1B0736),
          Color(0xFF2E0C59),
          Color(0xFF3B0764),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.45));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.45),
      arenaPaint,
    );

    // Hardwood Basketball Court Flooring
    final courtTopY = size.height * 0.42;
    final courtHeight = size.height - courtTopY;

    final courtShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFD97706),
        Color(0xFFB45309),
        Color(0xFF92400E),
        Color(0xFF78350F),
      ],
      stops: [0.0, 0.35, 0.7, 1.0],
    ).createShader(Rect.fromLTWH(0, courtTopY, size.width, courtHeight));

    final courtPaint = Paint()..shader = courtShader;
    canvas.drawRect(
      Rect.fromLTWH(0, courtTopY, size.width, courtHeight),
      courtPaint,
    );

    // Hardwood perspective lines
    final linePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 6; i++) {
      final startX = size.width * (i / 7.0);
      final endX = (size.width / 2) + (startX - size.width / 2) * 1.8;
      canvas.drawLine(
        Offset(startX, courtTopY),
        Offset(endX, size.height),
        linePaint,
      );
    }

    // Purple Free Throw Key
    final keyTopWidth = size.width * 0.42;
    final keyBottomWidth = size.width * 0.65;
    final keyTopY = courtTopY + 10.h;
    final keyBottomY = courtTopY + courtHeight * 0.62;

    final keyPath = Path()
      ..moveTo(size.width / 2 - keyTopWidth / 2, keyTopY)
      ..lineTo(size.width / 2 + keyTopWidth / 2, keyTopY)
      ..lineTo(size.width / 2 + keyBottomWidth / 2, keyBottomY)
      ..lineTo(size.width / 2 - keyBottomWidth / 2, keyBottomY)
      ..close();

    final keyFillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF7C3AED),
          Color(0xFF6D28D9),
          Color(0xFF5B21B6),
        ],
      ).createShader(Rect.fromLTWH(0, keyTopY, size.width, keyBottomY - keyTopY));

    canvas.drawPath(keyPath, keyFillPaint);

    final keyBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(keyPath, keyBorderPaint);

    // Free throw circle arc
    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, keyBottomY),
        radius: keyTopWidth * 0.38,
      ),
      0,
      math.pi,
      false,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Stylized Basketball Hoop Widget matching design
class _BasketballHoopWidget extends StatelessWidget {
  const _BasketballHoopWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Backboard
        Container(
          width: 190.w,
          height: 125.h,
          decoration: BoxDecoration(
            color: const Color(0xFF2E1065).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFF818CF8),
              width: 3.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66818CF8),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 75.w,
              height: 52.h,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2.5,
                ),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),

        // Rim & Net hanging below backboard
        Transform.translate(
          offset: Offset(0, -14.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Orange Rim
              Container(
                width: 64.w,
                height: 10.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFEA580C),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: const Color(0xFFF97316),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x88EA580C),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),

              // Woven Net
              CustomPaint(
                size: Size(54.w, 38.h),
                painter: _NetPainter(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom Net Painter
class _NetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final netPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final topWidth = size.width;
    final bottomWidth = size.width * 0.55;
    const segments = 5;

    // Draw vertical diamond lines
    for (int i = 0; i <= segments; i++) {
      final topX = (topWidth / segments) * i;
      final bottomX = (size.width - bottomWidth) / 2 + (bottomWidth / segments) * i;
      canvas.drawLine(
        Offset(topX, 0),
        Offset(bottomX, size.height),
        netPaint,
      );
    }

    // Draw horizontal diamond rings
    for (int j = 1; j <= 3; j++) {
      final y = (size.height / 4) * j;
      final progress = j / 4.0;
      final currentWidth = topWidth - (topWidth - bottomWidth) * progress;
      final startX = (size.width - currentWidth) / 2;
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + currentWidth, y),
        netPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// High-resolution 3D-shaded Basketball Widget with authentic seams
class _BasketballWidget extends StatelessWidget {
  const _BasketballWidget({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final s = size.w;

    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.35, -0.4),
          radius: 0.85,
          colors: [
            Color(0xFFFB923C),
            Color(0xFFEA580C),
            Color(0xFFC2410C),
            Color(0xFF9A3412),
          ],
          stops: [0.0, 0.45, 0.8, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withValues(alpha: 0.4),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _BasketballSeamsPainter(),
      ),
    );
  }
}

/// Basketball Seams Painter (seams + ribs)
class _BasketballSeamsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final seamPaint = Paint()
      ..color = const Color(0xFF1F2937).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Vertical seam
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      seamPaint,
    );

    // Horizontal seam
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      seamPaint,
    );

    // Left curved arc
    final leftArcPath = Path()
      ..moveTo(center.dx - radius * 0.7, 0)
      ..quadraticBezierTo(
        center.dx - radius * 0.15,
        center.dy,
        center.dx - radius * 0.7,
        size.height,
      );
    canvas.drawPath(leftArcPath, seamPaint);

    // Right curved arc
    final rightArcPath = Path()
      ..moveTo(center.dx + radius * 0.7, 0)
      ..quadraticBezierTo(
        center.dx + radius * 0.15,
        center.dy,
        center.dx + radius * 0.7,
        size.height,
      );
    canvas.drawPath(rightArcPath, seamPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Prompt banner with pulsing text: "Swipe to Shoot!"
class _SwipePromptBanner extends StatefulWidget {
  @override
  State<_SwipePromptBanner> createState() => _SwipePromptBannerState();
}

class _SwipePromptBannerState extends State<_SwipePromptBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final scale = 1.0 + (_anim.value * 0.08);

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_upward_rounded,
                  color: const Color(0xFFFFD54F),
                  size: 22.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Swipe to Shoot!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Color(0x88000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Waiting banner shown on opponent's device
class _OpponentWaitingBanner extends StatelessWidget {
  const _OpponentWaitingBanner({required this.shooterName});

  final String shooterName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: const Color(0xFFFFD54F),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation(Color(0xFFFFD54F)),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            '$shooterName is shooting...',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Result Overlay ("Basket Bonus +2XP" or "Oops! So Close! +0 XP")
class _ShootoutResultOverlay extends StatelessWidget {
  const _ShootoutResultOverlay({required this.result});

  final dynamic result; // GameShootoutResultEvent

  @override
  Widget build(BuildContext context) {
    final isMade = result.made == true;
    final xpText = isMade ? '+2XP' : '+0 XP';
    final ribbonTitle = isMade ? 'Congratulations' : 'Oops! So Close!';

    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Character portrait (Faith with basketball)
            Container(
              width: 130.w,
              height: 130.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isMade
                      ? [
                          const Color(0xFFFFD54F),
                          const Color(0xFFF59E0B),
                          Colors.transparent,
                        ]
                      : [
                          const Color(0xFF9CA3AF),
                          const Color(0xFF6B7280),
                          Colors.transparent,
                        ],
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/characters/hero_faith.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.sports_basketball,
                    size: 80.sp,
                    color: const Color(0xFFEA580C),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Purple/Magenta Ribbon Banner
            Container(
              padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF9333EA),
                    Color(0xFFA855F7),
                    Color(0xFF7E22CE),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66A855F7),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                ribbonTitle,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // "Basket Bonus" Label
            Text(
              'Basket Bonus',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    color: Color(0x88000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),

            // "+2XP" or "+0 XP" Display
            Text(
              xpText,
              style: TextStyle(
                fontSize: 42.sp,
                fontWeight: FontWeight.w900,
                color: isMade ? const Color(0xFFFFD54F) : const Color(0xFFE5E7EB),
                shadows: [
                  Shadow(
                    color: isMade ? const Color(0xFFB45309) : Colors.black45,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

