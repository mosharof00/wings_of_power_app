import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/core/theme/app_radius.dart';

import 'app_text.dart';

/// Category tile with a title and a story count.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.title,
    required this.storyCount,
    this.cover,
    this.onTap,
    this.width,
  });

  final String title;
  final int storyCount;
  final ImageProvider? cover;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 150.w,
      height: 180.h,
      child: Material(
        color: AppColor.cream,
        borderRadius: BorderRadius.circular(AppRadius.card.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (cover != null) Image(image: cover!, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColor.secondary.withValues(alpha: 0.72),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColor.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppText(
                      '$storyCount Stories',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColor.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
