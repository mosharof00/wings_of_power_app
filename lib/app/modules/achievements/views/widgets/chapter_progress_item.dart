import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/achievement_models.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

class ChapterProgressItem extends StatelessWidget {
  const ChapterProgressItem({super.key, required this.chapter});

  final ChapterProgressItemModel chapter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Book cover thumbnail
          Container(
            width: 54.w,
            height: 72.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColor.primary.withValues(alpha: 0.3)),
              color: AppColor.cream,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9.r),
              child: chapter.coverAsset != null
                  ? Image.asset(chapter.coverAsset!, fit: BoxFit.cover)
                  : Assets.bookCovers.coverTheGoldenPearl2.image(fit: BoxFit.cover),
            ),
          ),

          SizedBox(width: 14.w),

          // Chapter details & progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chapter Title (e.g. Chapter 1)
                Text(
                  chapter.chapterTitle,
                  style: GoogleFonts.nunito(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primary,
                  ),
                ),

                SizedBox(height: 2.h),

                // Chapter Name (e.g. The Girl Who Believed)
                Text(
                  chapter.chapterName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColor.secondary,
                  ),
                ),

                SizedBox(height: 4.h),

                // Pages & minutes info
                Row(
                  children: [
                    Text(
                      '${chapter.pageCount} pages',
                      style: GoogleFonts.nunito(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.subtitle,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Text(
                        '·',
                        style: TextStyle(
                          color: AppColor.subtitle,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${chapter.readingMinutes} mins',
                      style: GoogleFonts.nunito(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.subtitle,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Linear progress bar with percentage
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: chapter.progressPercent / 100.0,
                          backgroundColor: const Color(0xFFF0EBF8),
                          color: AppColor.primary,
                          minHeight: 6.h,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      '${chapter.progressPercent}%',
                      style: GoogleFonts.nunito(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColor.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
