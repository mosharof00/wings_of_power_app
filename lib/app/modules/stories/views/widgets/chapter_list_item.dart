import 'package:cached_network_image/cached_network_image.dart';
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

  Widget _buildThumbnail() {
    if (chapter.coverUrl != null && chapter.coverUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: chapter.coverUrl!,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(color: AppColor.cream),
        errorWidget: (_, _, _) => _fallbackThumb(),
      );
    }
    if (chapter.assetPath != null && chapter.assetPath!.isNotEmpty) {
      return Image.asset(
        chapter.assetPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallbackThumb(),
      );
    }
    return _fallbackThumb();
  }

  Widget _fallbackThumb() {
    return Container(
      color: AppColor.cream,
      alignment: Alignment.center,
      child: Icon(
        Icons.menu_book_rounded,
        size: 24.sp,
        color: AppColor.primary.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildTrailing() {
    if (chapter.isCompleted) {
      return Container(
        width: 32.w,
        height: 32.w,
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
        width: 32.w,
        height: 32.w,
        decoration: const BoxDecoration(
          color: Color(0xFFE5E7EB),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.lock_rounded,
          color: Color(0xFF9CA3AF),
          size: 16.sp,
        ),
      );
    }

    return Container(
      width: 32.w,
      height: 32.w,
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
      padding: EdgeInsets.all(12.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Row(
          children: [
            // Chapter thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: SizedBox(
                width: 68.w,
                height: 68.w,
                child: _buildThumbnail(),
              ),
            ),
            SizedBox(width: 12.w),

            // Chapter details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chapter ${chapter.chapterNumber}',
                    style: GoogleFonts.nunito(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.subtitle,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    chapter.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColor.secondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 13.sp,
                        color: AppColor.secondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${chapter.pageCount} pages',
                        style: GoogleFonts.nunito(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.secondary,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Icon(
                        Icons.access_time_rounded,
                        size: 13.sp,
                        color: AppColor.secondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${chapter.estimatedMinutes} mins',
                        style: GoogleFonts.nunito(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.secondary,
                        ),
                      ),
                      if (chapter.hasQuiz) ...[
                        SizedBox(width: 10.w),
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
                    SizedBox(height: 6.h),
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
            SizedBox(width: 8.w),

            // Trailing status indicator
            _buildTrailing(),
          ],
        ),
      ),
    );
  }
}
