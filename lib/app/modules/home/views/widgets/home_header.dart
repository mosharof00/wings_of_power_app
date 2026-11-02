import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/app_svg_icon.dart';
import 'package:wings_of_power_app/app/global/widgets/app_text.dart';
import 'package:wings_of_power_app/app/global/widgets/points_chip.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.greeting,
    required this.subtitle,
    required this.points,
    this.avatarUrl,
    this.onBellTap,
  });

  final String greeting;
  final String subtitle;
  final int points;
  final String? avatarUrl;
  final VoidCallback? onBellTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar circle
        Container(
          width: 46.w,
          height: 46.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColor.white,
            border: Border.all(color: AppColor.white, width: 2.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: avatarUrl != null && avatarUrl!.startsWith('http')
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _defaultAvatar(),
                  )
                : _defaultAvatar(),
          ),
        ),
        SizedBox(width: 10.w),
        // Greeting & points
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: AppText(
                      greeting,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColor.secondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18.sp,
                          ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  PointsChip(count: points),
                ],
              ),
              SizedBox(height: 2.h),
              AppText(
                subtitle,
                maxLines: 1,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColor.subtitle,
                      fontWeight: FontWeight.w500,
                      fontSize: 13.sp,
                    ),
              ),
            ],
          ),
        ),
        // Bell icon button
        GestureDetector(
          onTap: onBellTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.white,
              border: Border.all(color: const Color(0xFFFFD7B5), width: 1.5.w),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1AEB7E34),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: AppSvgIcon(
                Assets.icons.icBell.path,
                size: 20.w,
                color: AppColor.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _defaultAvatar() {
    return Assets.characters.heroSamantha.image(
      fit: BoxFit.cover,
    );
  }
}
