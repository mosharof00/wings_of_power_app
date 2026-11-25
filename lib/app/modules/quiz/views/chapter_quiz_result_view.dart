import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/global/widgets/app_svg_icon.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

import '../../../data/models/quiz_models.dart';
import '../../../global/widgets/app_sunburst_background.dart';
import '../controllers/quiz_controller.dart';

class ChapterQuizResultView extends GetView<QuizController> {
  const ChapterQuizResultView({super.key, required this.result});

  final CompleteAttemptResponseModel result;

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
              final score = result.scoreCorrect;
              final total = result.scoreTotal;
              final points = result.pointsAwarded;
              final fraction = total > 0
                  ? (score / total).clamp(0.0, 1.0)
                  : 0.0;
              final percent = (fraction * 100).round();
              final isBusy = controller.isSubmitting.value;
              final error = controller.submitError.value;
              final isPerfect = score == total && total > 0;

              String title;
              String subtitle;

              if (isPerfect) {
                title = 'Amazing Work!';
                subtitle = 'You got all $total questions right!';
              } else if (score >= 3) {
                title = 'Good Effort!';
                subtitle = 'You answered $score out of $total correctly.';
              } else {
                title = 'Keep Going!';
                subtitle = 'You answered $score out of $total correctly.';
              }

              return Stack(
                children: [
                  // Gabriel on the right side behind card
                  Positioned(
                    top: 165.h,
                    right: 0.w,
                    child: Image.asset(
                      Assets.characters.gabrielHostDone.path,

                      height: 210.h,
                      fit: BoxFit.contain,
                    ),
                  ),

                  Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 2. Three Golden Stars Header
                          _buildStarsHeader(),

                          SizedBox(height: 32.h),

                          // 3. Points Awarded Pill
                          _buildPointsPill(points),

                          SizedBox(height: 16.h),

                          // 4. Gabriel thumbs up peaking behind the card + Score Card

                          // Result Card (Cream)
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 20.w),
                            padding: EdgeInsets.fromLTRB(
                              20.w,
                              24.h,
                              20.w,
                              20.h,
                            ),
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

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Quiz Score',
                                      style: GoogleFonts.nunito(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1E1B4B),
                                      ),
                                    ),
                                    Text(
                                      '$percent%',
                                      style: GoogleFonts.nunito(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1E1B4B),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 6.h),

                                LinearProgressIndicator(
                                  value: fraction,
                                  semanticsLabel: 'Quiz score',
                                  minHeight: 10.h,
                                  borderRadius: BorderRadius.circular(6.r),
                                  backgroundColor: const Color(0xFFE5E7EB),
                                  color: const Color(0xFF22C55E),
                                ),
                                if (error.isNotEmpty) ...[
                                  SizedBox(height: 10.h),
                                  Text(error, textAlign: TextAlign.center),
                                ],

                                SizedBox(height: 22.h),

                                // CTA 1: Next Chapter (Orange)
                                GestureDetector(
                                  onTap: isBusy ? null : controller.nextChapter,
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
                                        isBusy ? 'Opening…' : 'Next Chapter',
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
                                          color: Colors.black.withValues(
                                            alpha: 0.05,
                                          ),
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
                                    onTap: isBusy ? null : controller.playAgain,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 4.h,
                                      ),
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
                    ),
                  ),
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
              colors: [Color(0xFFBAE6FD), Color(0xFFE0F2FE), Color(0xFFF0F9FF)],
            ),
          ),
        ),

        const Positioned.fill(
          child: ClipRect(
            child: AppSunburstBackground(
              centerAlignment: Alignment(0, -0.55),
              rayColor: Colors.white,
              secondaryRayColor: Color(0xFFDFF4FF),
              opacity: 0.40,
            ),
          ),
        ),
        // Perspective road at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 180.h,
          child: CustomPaint(painter: _RoadPerspectivePainter()),
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
        Transform.rotate(angle: -0.15, child: _buildBigStar(54.w)),

        // Center Star (larger)
        _buildBigStar(100.w),

        // Right Star (angled slightly right)
        Transform.rotate(angle: 0.15, child: _buildBigStar(54.w)),
      ],
    );
  }

  Widget _buildBigStar(double size) {
    return Image.asset(
      Assets.images.quizResultStar.path,
      width: size + 8.w,
      height: size + 8.w,
    );
  }

  Widget _buildPointsPill(int points) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey, width: 1.w),
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
          AppSvgIcon(Assets.icons.icPointsCoin.path, width: 22.w, height: 22.w),
        ],
      ),
    );
  }
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
