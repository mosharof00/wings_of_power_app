import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';

/// Chapter, reading, and quiz result bar. [value] is 0 to 1.
class LinearProgressBar extends StatelessWidget {
  const LinearProgressBar({
    super.key,
    required this.value,
    this.height,
  });

  final double value;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final barHeight = height ?? 8.h;
    return Semantics(
      label: 'Progress',
      value: '${(clamped * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(barHeight),
        child: SizedBox(
          height: barHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: AppColor.chip),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: clamped,
                child: const ColoredBox(color: AppColor.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
