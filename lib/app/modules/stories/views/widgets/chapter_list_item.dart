import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/story_models.dart';

class ChapterListItem extends StatelessWidget {
  const ChapterListItem({
    super.key,
    required this.chapter,
    required this.onTap,
    required this.onQuizTap,
  });

  final ChapterModel chapter;
  final VoidCallback onTap;
  final VoidCallback onQuizTap;

  Widget _buildTrailing() {
    if (chapter.isCompleted) {
      return Container(
        width: 36.w,
        height: 36.w,
        decoration: const BoxDecoration(
          color: Color(0xFF22C55E),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: 20.sp,
        ),
      );
    }

    if (chapter.isLocked) {
      return Container(
        width: 36.w,
        height: 36.w,
        decoration: const BoxDecoration(
          color: Color(0xFFE5E7EB),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.lock_rounded,
          color: const Color(0xFF9CA3AF),
          size: 18.sp,
        ),
      );
    }

    return Container(
      width: 36.w,
      height: 36.w,
      decoration: const BoxDecoration(
        color: Color(0xFFFDEEE5),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.arrow_forward_rounded,
        color: AppColor.primary,
        size: 18.sp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColor.chip.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Chapter details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chapter ${chapter.chapterNumber}',
                        style: GoogleFonts.nunito(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.subtitle,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        chapter.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColor.secondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            size: 15.sp,
                            color: const Color(0xFF6B46C1),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${chapter.pageCount} pages',
                            style: GoogleFonts.nunito(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B46C1),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Icon(
                            Icons.access_time_rounded,
                            size: 15.sp,
                            color: const Color(0xFF6B46C1),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${chapter.estimatedMinutes} mins',
                            style: GoogleFonts.nunito(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B46C1),
                            ),
                          ),
                          if (chapter.hasQuiz) ...[
                            SizedBox(width: 12.w),
                            GestureDetector(
                              onTap: onQuizTap,
                              child: Text(
                                'Quiz',
                                style: GoogleFonts.nunito(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF2563EB),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (chapter.progressPercent != null &&
                          !chapter.isCompleted &&
                          chapter.progressPercent! > 0) ...[
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.r),
                                child: LinearProgressIndicator(
                                  value: chapter.progressPercent!,
                                  minHeight: 5.h,
                                  backgroundColor: const Color(0xFFE5E7EB),
                                  valueColor: const AlwaysStoppedAnimation(
                                    Color(0xFF22C55E),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${(chapter.progressPercent! * 100).toInt()}%',
                              style: GoogleFonts.nunito(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF22C55E),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 12.w),

                // Trailing status indicator / arrow
                _buildTrailing(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
