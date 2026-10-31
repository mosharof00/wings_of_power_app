import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';

enum StepProgressStyle { dots, stars }

/// Onboarding page dots, or the filled stars on a chapter quiz.
class StepProgress extends StatelessWidget {
  const StepProgress({
    super.key,
    required this.count,
    required this.index,
    this.style = StepProgressStyle.dots,
  });

  final int count;

  /// Active dot, or the number of filled stars.
  final int index;
  final StepProgressStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) SizedBox(width: 6.w),
          style == StepProgressStyle.dots ? _dot(i) : _star(i),
        ],
      ],
    );
  }

  Widget _dot(int i) {
    final active = i == index;
    return Container(
      width: active ? 8.w : 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: active ? AppColor.primary : AppColor.primaryDisable,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _star(int i) {
    final filled = i < index;
    return Icon(
      filled ? Icons.star_rounded : Icons.star_outline_rounded,
      size: 18.sp,
      color: filled ? AppColor.gold : AppColor.primaryDisable,
    );
  }
}
