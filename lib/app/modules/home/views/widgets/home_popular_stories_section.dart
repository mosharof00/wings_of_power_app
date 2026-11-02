import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/home_models.dart';
import 'package:wings_of_power_app/app/global/widgets/app_text.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

class HomePopularStoriesSection extends StatelessWidget {
  const HomePopularStoriesSection({
    super.key,
    required this.stories,
    this.onSeeAll,
    this.onStoryTap,
  });

  final List<HomeStoryModel> stories;
  final VoidCallback? onSeeAll;
  final ValueChanged<HomeStoryModel>? onStoryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  'Popular Stories',
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColor.secondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                      ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: onSeeAll,
                child: AppText(
                  'See all',
                  style: TextStyle(
                    color: AppColor.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: stories.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColor.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: AppText(
                    'No stories found',
                    style: TextStyle(
                      color: AppColor.subtitle,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14.w,
                    mainAxisSpacing: 14.h,
                    childAspectRatio: 0.74,
                  ),
                  itemBuilder: (context, index) {
                    final story = stories[index];
                    return GestureDetector(
                      onTap: () => onStoryTap?.call(story),
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: _buildStoryCover(story),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            AppText(
                              story.title,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColor.secondary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.sp,
                                height: 1.2,
                              ),
                            ),
                            if (story.subtitle != null &&
                                story.subtitle!.isNotEmpty) ...[
                              SizedBox(height: 2.h),
                              AppText(
                                story.subtitle!,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColor.subtitle,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStoryCover(HomeStoryModel story) {
    if (story.coverUrl != null && story.coverUrl!.startsWith('http')) {
      return Image.network(
        story.coverUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, _, _) => _defaultCover(story),
      );
    }
    if (story.assetPath != null && story.assetPath!.isNotEmpty) {
      return Image.asset(
        story.assetPath!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, _, _) => _defaultCover(story),
      );
    }
    return _defaultCover(story);
  }

  Widget _defaultCover(HomeStoryModel story) {
    final title = story.title.toLowerCase();
    if (title.contains('golden pearl') && title.contains('1')) {
      return Assets.bookCovers.coverTheGoldenPearl1.image(fit: BoxFit.cover);
    }
    if (title.contains('golden pearl')) {
      return Assets.bookCovers.coverTheGoldenPearl2.image(fit: BoxFit.cover);
    }
    if (title.contains('thieves') || title.contains('theives')) {
      return Assets.bookCovers.coverCityOfThieves.image(fit: BoxFit.cover);
    }
    if (title.contains('ties that bind')) {
      return Assets.bookCovers.coverTheTiesThatBindUs.image(fit: BoxFit.cover);
    }
    return Assets.images.placeholderImage.image(fit: BoxFit.cover);
  }
}
