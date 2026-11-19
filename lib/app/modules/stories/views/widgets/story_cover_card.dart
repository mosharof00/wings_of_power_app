import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/story_models.dart';
import 'package:wings_of_power_app/app/global/widgets/cached_image.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

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
    final url = story.coverUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return CachedImage(
        imgUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
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
    return Image.asset(
      Assets.images.placeholderImage.path,
      fit: BoxFit.cover,
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
