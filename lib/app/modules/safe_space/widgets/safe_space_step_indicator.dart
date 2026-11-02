import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/custom_icon_button.dart';

class SafeSpaceStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;

  const SafeSpaceStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
    required this.onBack,
  });

  static const Color activeGreen = Color(0xFF5CC81D);
  static const Color inactivePill = Color(0xFFE5E2EC);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          CustomIconButton(
            onPressed: onBack,
            size: 40.w,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= totalSteps; i++) ...[
                  if (i > 1) SizedBox(width: 8.w),
                  Expanded(
                    child: Container(
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: i <= currentStep ? activeGreen : inactivePill,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 14.w),
          Text(
            '$currentStep/$totalSteps',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
