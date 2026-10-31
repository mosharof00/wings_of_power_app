import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../../../../gen/assets.gen.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // The binding is lazy. Reading the controller is what starts the timer.
    if (!controller.initialized) return const SizedBox.shrink();
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            Assets.backgrounds.bgSplashSky.path,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 5),
                Image.asset(
                  Assets.logos.logoWordmark.path,
                  width: 320.w,
                  fit: BoxFit.contain,
                ),
                const Spacer(flex: 4),
                const _SplashSpinner(),
                SizedBox(height: 64.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashSpinner extends StatefulWidget {
  const _SplashSpinner();

  @override
  State<_SplashSpinner> createState() => _SplashSpinnerState();
}

class _SplashSpinnerState extends State<_SplashSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turns = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _turns.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _turns,
      child: CustomPaint(
        size: Size.square(40.w),
        painter: const _DotRingPainter(),
      ),
    );
  }
}

class _DotRingPainter extends CustomPainter {
  const _DotRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    const count = 10;
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2 - math.pi / 2;
      final opacity = 0.25 + (i / count) * 0.75;
      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        size.width * 0.07,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
