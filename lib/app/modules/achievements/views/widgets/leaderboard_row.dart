import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/achievement_models.dart';
import 'package:wings_of_power_app/app/global/widgets/points_chip.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({super.key, required this.student});

  final LeaderboardItemModel student;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = student.isCurrentStudent;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColor.cream : AppColor.white,
        borderRadius: BorderRadius.circular(16.r),
        border: isHighlighted
            ? Border.all(color: AppColor.primary, width: 1.5.w)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank label
          SizedBox(
            width: 32.w,
            child: Text(
              '#${student.rank}',
              style: GoogleFonts.nunito(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: isHighlighted ? AppColor.primary : AppColor.secondary,
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // Student Avatar
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.white,
              border: Border.all(
                color: isHighlighted ? AppColor.primary : const Color(0xFFE9E5F0),
                width: 1.5.w,
              ),
            ),
            child: ClipOval(
              child: student.avatarUrl != null &&
                      student.avatarUrl!.startsWith('http')
                  ? Image.network(
                      student.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _defaultAvatar(),
                    )
                  : _defaultAvatar(),
            ),
          ),

          SizedBox(width: 12.w),

          // Student Name
          Expanded(
            child: Text(
              student.nickname,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: AppColor.secondary,
              ),
            ),
          ),

          // Points chip
          PointsChip(count: student.kindnessPoints),
        ],
      ),
    );
  }

  Widget _defaultAvatar() {
    return Assets.characters.heroSamantha.image(
      fit: BoxFit.cover,
    );
  }
}
