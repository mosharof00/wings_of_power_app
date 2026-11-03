import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

class GameCongratulationsDialog extends StatelessWidget {
  const GameCongratulationsDialog({
    super.key,
    required this.onPlayNow,
    required this.onHowToPlay,
    this.onClose,
  });

  final VoidCallback onPlayNow;
  final VoidCallback onHowToPlay;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          // Sunburst background
          CustomPaint(
            size: Size.infinite,
            painter: _SunburstPainter(),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // Character with basketball
                  Assets.characters.homePlayGame.image(
                    height: 280.h,
                    fit: BoxFit.contain,
                  ),
                  Transform.translate(
                    offset: Offset(0, -20.h),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 28.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF6EB),
                        borderRadius: BorderRadius.circular(28.r),
                        border: Border.all(
                          color: const Color(0xFFFFDFC8),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Congratulations!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E1B4B),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'You’ve unlocked the Basketball Game show.\nYou can play the game anytime',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15.sp,
                              height: 1.4,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          // Play Now Button
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              onPressed: onPlayNow,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE86726),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26.r),
                                ),
                              ),
                              child: Text(
                                'Play Now',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          // How to Play Button
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: OutlinedButton(
                              onPressed: onHowToPlay,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFE86726),
                                side: const BorderSide(
                                  color: Color(0xFFFFDFC8),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26.r),
                                ),
                              ),
                              child: Text(
                                'How to Play',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFE86726),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SunburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.35);
    final radius = math.sqrt(size.width * size.width + size.height * size.height);

    final bgPaint = Paint()..color = const Color(0xFFBAE6FD);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final rayPaint = Paint()..color = const Color(0xFFE0F2FE);
    const int rayCount = 18;
    const double angleStep = (2 * math.pi) / rayCount;

    for (int i = 0; i < rayCount; i += 2) {
      final startAngle = i * angleStep;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + radius * math.cos(startAngle),
          center.dy + radius * math.sin(startAngle),
        )
        ..lineTo(
          center.dx + radius * math.cos(startAngle + angleStep),
          center.dy + radius * math.sin(startAngle + angleStep),
        )
        ..close();
      canvas.drawPath(path, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

