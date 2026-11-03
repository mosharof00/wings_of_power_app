import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GameCountdownOverlay extends StatelessWidget {
  const GameCountdownOverlay({
    super.key,
    required this.countdownValue,
  });

  final int countdownValue;

  @override
  Widget build(BuildContext context) {
    final digit = countdownValue > 0 ? countdownValue.toString() : '1';

    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: const Color(0x992E0854),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Giant 3D Golden Digit
                  Stack(
                    children: [
                      // Bottom shadow for 3D look
                      Text(
                        digit,
                        style: TextStyle(
                          fontSize: 160.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 12.w
                            ..color = const Color(0xFFC05621),
                        ),
                      ),
                      // Inner fill
                      Text(
                        digit,
                        style: TextStyle(
                          fontSize: 160.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          color: const Color(0xFFFFB74D),
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 8),
                              blurRadius: 4,
                              color: Color(0x66000000),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Get Ready....',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: const [
                        Shadow(
                          offset: Offset(0, 3),
                          blurRadius: 8,
                          color: Color(0x88000000),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
