import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/story_models.dart';

class StoryCoverCard extends StatelessWidget {
  const StoryCoverCard({
    super.key,
    required this.story,
    required this.onTap,
    this.width,
  });

  final StorySummaryModel story;
  final VoidCallback onTap;
  final double? width;

  Widget _buildCoverImage() {
    if (story.coverUrl != null && story.coverUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: story.coverUrl!,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(
          color: AppColor.cream,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (_, _, _) => _fallbackCover(),
      );
    }
    if (story.assetPath != null && story.assetPath!.isNotEmpty) {
      return Image.asset(
        story.assetPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallbackCover(),
      );
    }
    return _fallbackCover();
  }

  Widget _fallbackCover() {
    return Container(
      color: AppColor.cream,
      alignment: Alignment.center,
      child: Icon(
        Icons.menu_book_rounded,
        size: 36.sp,
        color: AppColor.primary.withValues(alpha: 0.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 156.w,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: _buildCoverImage(),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                story.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColor.secondary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
