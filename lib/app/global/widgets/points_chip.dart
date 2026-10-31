import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/core/theme/app_radius.dart';

import '../../../gen/assets.gen.dart';
import 'app_svg_icon.dart';
import 'app_text.dart';

/// Lavender coin chip used on home, profile, points, quiz result, and the leaderboard.
class PointsChip extends StatelessWidget {
  const PointsChip({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22.h,
      padding: EdgeInsets.only(left: 2.w, right: 8.w),
      decoration: BoxDecoration(
        color: AppColor.chip,
        borderRadius: BorderRadius.circular(AppRadius.chip.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvgIcon(Assets.icons.icPointsCoin.path, size: 16.w),
          SizedBox(width: 4.w),
          AppText(
            '$count',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColor.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
