import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/app_text.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

class HomeExploreMoreSection extends StatelessWidget {
  const HomeExploreMoreSection({
    super.key,
    this.onLeaderboardTap,
    this.onSafeSpaceReportTap,
  });

  final VoidCallback? onLeaderboardTap;
  final VoidCallback? onSafeSpaceReportTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: AppText(
            'Explore More',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColor.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                ),
          ),
        ),
        SizedBox(height: 14.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Expanded(
                child: _ExploreCard(
                  image: Assets.images.leaderboard.path,
                  title: 'Leaderboard',
                  onTap: onLeaderboardTap,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _ExploreCard(
                  image: Assets.images.safeSpaceReport.path,
                  title: 'Safe Space Report',
                  onTap: onSafeSpaceReportTap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExploreCard extends StatelessWidget {
  const _ExploreCard({
    required this.image,
    required this.title,
    this.onTap,
  });

  final String image;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1.6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.r),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          AppText(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              color: AppColor.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
