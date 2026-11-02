import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';
import '../controllers/quiz_controller.dart';

class ChapterQuizResultView extends GetView<QuizController> {
  const ChapterQuizResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBEBFE),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Sunburst / Sky background with road perspective
          _buildSunburstBackground(),

          SafeArea(
            child: Obx(() {
              final score = controller.scoreCorrect.value;
              final total = controller.scoreTotal.value;
              final points = controller.pointsAwarded.value > 0
                  ? controller.pointsAwarded.value
                  : score * 2;
              final isPerfect = score == total && total > 0;

              String title;
              String subtitle;

              if (isPerfect) {
                title = 'Amazing Work!';
                subtitle =
                    'You got every question right! You’ve\nanswered $score correct answer out of $total';
              } else if (score >= 3) {
                title = 'Good Effort!';
                subtitle =
                    'Every question is a chance to learn.You’ve\nanswered $score correct answer out of $total';
              } else {
                title = 'Keep Going!';
                subtitle =
                    'You’re learning something new every time.\nYou’ve answered $score correct answer out of $total';
              }

              return Column(
                children: [
                  const Spacer(flex: 2),

                  // 2. Three Golden Stars Header
                  _buildStarsHeader(),

                  SizedBox(height: 12.h),

                  // 3. Points Awarded Pill
                  _buildPointsPill(points),

                  SizedBox(height: 16.h),

                  // 4. Gabriel thumbs up peaking behind the card + Score Card
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Gabriel on the right side behind card
                      Positioned(
                        top: -65.h,
                        right: 20.w,
                        child: Image.asset(
                          'assets/characters/gabriel_host.png',
                          height: 110.h,
                          fit: BoxFit.contain,
                        ),
                      ),

                      // Result Card (Cream)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 20.w),
                        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8EE),
                          borderRadius: BorderRadius.circular(28.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E1B4B),
                              ),
                            ),

                            SizedBox(height: 8.h),

                            // Subtitle
                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4B5563),
                                height: 1.35,
                              ),
                            ),

                            SizedBox(height: 18.h),

                            // Progress row: "Your Progress" and "10%"
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Your Progress',
                                  style: GoogleFonts.nunito(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1E1B4B),
                                  ),
                                ),
                                Text(
                                  '10%',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1E1B4B),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 6.h),

                            // Green progress bar drawn at exactly 10% per task requirement
                            Container(
                              height: 10.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: 0.10, // Exactly 10% as drawn on PNGs
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 22.h),

                            // CTA 1: Next Chapter (Orange)
                            GestureDetector(
                              onTap: controller.nextChapter,
                              child: Container(
                                width: double.infinity,
                                height: 48.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE06D28),
                                  borderRadius: BorderRadius.circular(24.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE06D28)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Next Chapter',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 12.h),

                            // CTA 2: Back to Story (White)
                            GestureDetector(
                              onTap: controller.backToStory,
                              child: Container(
                                width: double.infinity,
                                height: 48.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Back to Story',
                                    style: GoogleFonts.nunito(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFE06D28),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // CTA 3: Play Again! (Only if NOT 5/5 perfect score)
                            if (!isPerfect) ...[
                              SizedBox(height: 12.h),
                              GestureDetector(
                                onTap: controller.playAgain,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  child: Text(
                                    'Play Again!',
                                    style: GoogleFonts.nunito(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF312E81),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 3),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSunburstBackground() {
    return Stack(
      children: [
        // Sky gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFBAE6FD),
                Color(0xFFE0F2FE),
                Color(0xFFF0F9FF),
              ],
            ),
          ),
        ),

        // Custom painter for light radial sunburst rays
        CustomPaint(
          size: Size.infinite,
          painter: _SunburstPainter(),
        ),

        // Perspective road at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 180.h,
          child: CustomPaint(
            painter: _RoadPerspectivePainter(),
          ),
        ),
      ],
    );
  }

  Widget _buildStarsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Left Star (angled slightly left)
        Transform.rotate(
          angle: -0.15,
          child: _buildBigStar(64.w),
        ),

        SizedBox(width: 6.w),

        // Center Star (larger)
        _buildBigStar(88.w),

        SizedBox(width: 6.w),

        // Right Star (angled slightly right)
        Transform.rotate(
          angle: 0.15,
          child: _buildBigStar(64.w),
        ),
      ],
    );
  }

  Widget _buildBigStar(double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // White outline glow
        SvgPicture.asset(
          'assets/icons/ic_quiz_star.svg',
          width: size + 8.w,
          height: size + 8.w,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
        // Golden Star
        SvgPicture.asset(
          'assets/icons/ic_quiz_star.svg',
          width: size,
          height: size,
        ),
      ],
    );
  }

  Widget _buildPointsPill(int points) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+$points Points',
            style: GoogleFonts.nunito(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4338CA),
            ),
          ),
          SizedBox(width: 8.w),
          SvgPicture.asset(
            Assets.icons.icPointsCoin.path,
            width: 22.w,
            height: 22.w,
          ),
        ],
      ),
    );
  }
}

class _SunburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height * 0.18);
    const numRays = 16;
    final maxRadius = size.height * 1.2;

    for (int i = 0; i < numRays; i += 2) {
      final angle1 = (i * 2 * 3.14159) / numRays;
      final angle2 = ((i + 1) * 2 * 3.14159) / numRays;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + maxRadius * (angle1 > 0 ? 1 : -1),
          center.dy + maxRadius * (angle1 > 1.57 ? 1 : -1),
        )
        ..lineTo(
          center.dx + maxRadius * (angle2 > 0 ? 1 : -1),
          center.dy + maxRadius * (angle2 > 1.57 ? 1 : -1),
        )
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoadPerspectivePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.45, 0)
      ..lineTo(size.width * 0.55, 0)
      ..lineTo(size.width * 0.68, size.height)
      ..lineTo(size.width * 0.32, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

