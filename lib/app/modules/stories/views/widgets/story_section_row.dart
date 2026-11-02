import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/story_models.dart';
import 'story_cover_card.dart';

class StorySectionRow extends StatelessWidget {
  const StorySectionRow({
    super.key,
    required this.title,
    required this.stories,
    required this.onSeeAll,
    required this.onStoryTap,
  });

  final String title;
  final List<StorySummaryModel> stories;
  final VoidCallback onSeeAll;
  final ValueChanged<StorySummaryModel> onStoryTap;

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColor.secondary,
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See all',
                  style: GoogleFonts.nunito(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 200.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
            itemCount: stories.length,
            separatorBuilder: (_, _) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final story = stories[index];
              return StoryCoverCard(
                story: story,
                onTap: () => onStoryTap(story),
              );
            },
          ),
        ),
      ],
    );
  }
}
