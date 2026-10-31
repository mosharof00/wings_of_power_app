import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';

import 'app_text.dart';
import 'global_button.dart';

/// Full-page block for a failed fetch. Wrong-code and expired-code screens are separate.
class ErrorBlock extends StatelessWidget {
  const ErrorBlock({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              'Something went wrong',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColor.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            AppText(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColor.error,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              GlobalButton(
                text: 'Try again',
                width: 160.w,
                onTap: onRetry!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
