import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/home_models.dart';
import 'package:wings_of_power_app/app/global/widgets/app_text.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

class HomeBannerCard extends StatelessWidget {
  const HomeBannerCard({
    super.key,
    required this.banner,
    this.onAction,
  });

  final HomeBannerModel banner;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 160.h),
      decoration: BoxDecoration(
        color: AppColor.cream,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Illustration on right
          Positioned(
            right: 4.w,
            bottom: 0,
            child: SizedBox(
              height: banner.type == HomeBannerType.quiz ? 135.h : 155.h,
              child: _buildBannerImage(),
            ),
          ),
          // Content on left
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 128.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  banner.title,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColor.secondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                        height: 1.15,
                      ),
                ),
                if (banner.subtitle != null) ...[
                  SizedBox(height: 3.h),
                  AppText(
                    banner.subtitle!,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColor.secondary.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                          fontSize: 13.sp,
                        ),
                  ),
                ],
                if (banner.type == HomeBannerType.continueReading) ...[
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: AppText(
                          banner.storyTitle ?? 'Story',
                          maxLines: 1,
                          style: TextStyle(
                            color: AppColor.secondary,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      AppText(
                        banner.progressText ?? '1/1',
                        style: TextStyle(
                          color: AppColor.secondary,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3.r),
                    child: LinearProgressIndicator(
                      value: (banner.progressPercent ?? 0.0).clamp(0.0, 1.0),
                      minHeight: 6.h,
                      backgroundColor: const Color(0xFFE2DCBE),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF43A047),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: onAction,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33EE8940),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AppText(
                      banner.buttonText,
                      style: TextStyle(
                        color: AppColor.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerImage() {
    final path = banner.assetPath;
    if (path != null && path.isNotEmpty) {
      return Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _defaultImage(),
      );
    }
    return _defaultImage();
  }

  Widget _defaultImage() {
    switch (banner.type) {
      case HomeBannerType.startReading:
        return Assets.characters.homeBannerReader.image(fit: BoxFit.contain);
      case HomeBannerType.continueReading:
        return Assets.characters.homeBannerContinue.image(fit: BoxFit.contain);
      case HomeBannerType.quiz:
        return Assets.characters.homeBannerQuiz.image(fit: BoxFit.contain);
    }
  }
}
