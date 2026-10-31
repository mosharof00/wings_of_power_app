import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/core/theme/app_radius.dart';

import 'app_text.dart';

/// Cover tile for Popular Stories and the library grid.
class StoryCard extends StatelessWidget {
  const StoryCard({
    super.key,
    required this.title,
    this.subtitle,
    this.cover,
    this.onTap,
    this.width,
  });

  final String title;
  final String? subtitle;
  final ImageProvider? cover;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 140.w,
      child: Material(
        color: AppColor.cream,
        borderRadius: BorderRadius.circular(AppRadius.card.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 3 / 4,
                child: cover == null
                    ? const ColoredBox(color: AppColor.cream)
                    : Image(image: cover!, fit: BoxFit.cover),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColor.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null)
                      AppText(
                        subtitle!,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColor.subtitle,
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
