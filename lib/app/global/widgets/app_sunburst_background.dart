import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Continuously rotating radial “blue lights” / sunburst.
///
/// Reusable success / celebration backdrop. Place behind content in a [Stack]:
/// ```dart
/// Stack(
///   fit: StackFit.expand,
///   children: [
///     AppSunburstBackground(centerAlignment: Alignment(0, -0.24)),
///     // checkmark + copy…
///   ],
/// )
/// ```
class AppSunburstBackground extends StatefulWidget {
  const AppSunburstBackground({
    super.key,
    this.centerAlignment = Alignment.center,
    this.rayCount = 18,
    this.rayColor = const Color(0xFF9FD4F5),
    this.secondaryRayColor = const Color(0xFF9FD4F5),
    this.period = const Duration(seconds: 18),
    this.opacity = 0.85,
  });

  /// Where the burst originates inside this widget (usually behind a badge).
  final Alignment centerAlignment;

  /// Total wedges; every other wedge is filled.
  final int rayCount;

  /// Primary “blue light” wedges.
  final Color rayColor;

  /// Alternate soft wedges (peach / warm tint from join-success art).
  final Color secondaryRayColor;

  /// One full rotation duration.
  final Duration period;

  final double opacity;

  @override
  State<AppSunburstBackground> createState() => _AppSunburstBackgroundState();
}

class _AppSunburstBackgroundState extends State<AppSunburstBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant AppSunburstBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _controller.duration = widget.period;
      if (!_controller.isAnimating) _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * math.pi * 2,
              alignment: widget.centerAlignment,
              child: child,
            );
          },
          child: CustomPaint(
            painter: AppSunburstPainter(
              centerAlignment: widget.centerAlignment,
              rayCount: widget.rayCount,
              rayColor: widget.rayColor.withValues(alpha: widget.opacity),
              secondaryRayColor: widget.secondaryRayColor
                  .withValues(alpha: widget.opacity * 0.55),
            ),
          ),
        ),
      ),
    );
  }
}

class AppSunburstPainter extends CustomPainter {
  const AppSunburstPainter({
    required this.centerAlignment,
    required this.rayCount,
    required this.rayColor,
    required this.secondaryRayColor,
  });

  final Alignment centerAlignment;
  final int rayCount;
  final Color rayColor;
  final Color secondaryRayColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = centerAlignment.alongSize(size);
    final radius = size.longestSide;
    final sweep = (math.pi * 2) / rayCount;
    final primary = Paint()..color = rayColor;
    final secondary = Paint()..color = secondaryRayColor;

    for (var i = 0; i < rayCount; i++) {
      final paint = i.isEven ? primary : secondary;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2 + i * sweep,
          sweep * 0.92,
          false,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AppSunburstPainter oldDelegate) {
    return oldDelegate.centerAlignment != centerAlignment ||
        oldDelegate.rayCount != rayCount ||
        oldDelegate.rayColor != rayColor ||
        oldDelegate.secondaryRayColor != secondaryRayColor;
  }
}
