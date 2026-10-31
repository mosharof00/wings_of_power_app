import 'package:flutter/material.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/core/theme/app_radius.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'app_text.dart';
import 'step_progress.dart';

class GlobalLoading extends StatelessWidget {
  const GlobalLoading({super.key, this.size, this.color});

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.threeArchedCircle(
          color: color ?? AppColor.primary, size: size ?? 35.sp),
    );
  }
}

/// Cream card from Loading State.png. The character art stays on that screen.
class LoadingCard extends StatelessWidget {
  const LoadingCard({
    super.key,
    this.title = 'Loading',
    this.message = 'Please wait while I fetch the story for you!',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 18.h),
      decoration: BoxDecoration(
        color: AppColor.cream,
        borderRadius: BorderRadius.circular(AppRadius.card.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppColor.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          AppText(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColor.subtitle,
            ),
          ),
          SizedBox(height: 14.h),
          const StepProgress(count: 3, index: 0),
        ],
      ),
    );
  }
}
