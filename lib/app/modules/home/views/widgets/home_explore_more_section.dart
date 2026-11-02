import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/app_text.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

class HomeExploreMoreSection extends StatelessWidget {
  const HomeExploreMoreSection({
    super.key,
    this.onKindnessCornerTap,
    this.onAudioBooksTap,
    this.onSafeSpaceReportTap,
  });

  final VoidCallback? onKindnessCornerTap;
  final VoidCallback? onAudioBooksTap;
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExploreItem(
                image: Assets.images.exploreKindnessCorner.path,
                title: 'Kindness\nCorner',
                borderColor: const Color(0xFFFFE0B2),
                backgroundColor: const Color(0xFFFFF6DE),
                onTap: onKindnessCornerTap,
              ),
              _buildExploreItem(
                image: Assets.images.exploreAudioBooks.path,
                title: 'Audio\nBooks',
                borderColor: const Color(0xFFE1BEE7),
                backgroundColor: const Color(0xFFF3E5F5),
                onTap: onAudioBooksTap,
              ),
              _buildExploreItem(
                image: Assets.images.exploreSafeSpace.path,
                title: 'Safe Space\nReport',
                borderColor: const Color(0xFFFFCDD2),
                backgroundColor: const Color(0xFFFFEBEE),
                onTap: onSafeSpaceReportTap,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExploreItem({
    required String image,
    required String title,
    required Color borderColor,
    required Color backgroundColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 90.w,
        child: Column(
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
                border: Border.all(color: borderColor, width: 2.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
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
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
