import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/app_text.dart';
import 'package:wings_of_power_app/app/global/widgets/custom_appbar.dart';

/// Placeholder stub for Safe Space Report flow (implemented in T-APP-016).
class SafeSpaceStubView extends StatelessWidget {
  const SafeSpaceStubView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: CustomAppBar(
        title: 'Safe Space Report',
        showBackButton: true,
        onBackTap: () => Get.back(),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                'Safe Space Report',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColor.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              AppText(
                'Tell us what happened. Coming in T-APP-016.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColor.subtitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
