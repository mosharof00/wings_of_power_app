import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/achievement_models.dart';
import 'package:wings_of_power_app/app/global/widgets/points_chip.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

class LeaderboardPodium extends StatelessWidget {
  const LeaderboardPodium({super.key, required this.podium});

  final List<LeaderboardItemModel> podium;

  @override
  Widget build(BuildContext context) {
    if (podium.isEmpty) return const SizedBox.shrink();

    final rank1 = podium.firstWhere((p) => p.rank == 1, orElse: () => podium[0]);
    final rank2 = podium.firstWhere((p) => p.rank == 2, orElse: () => podium.length > 1 ? podium[1] : rank1);
    final rank3 = podium.firstWhere((p) => p.rank == 3, orElse: () => podium.length > 2 ? podium[2] : rank1);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place (Left)
          Expanded(
            child: _buildPodiumColumn(
              student: rank2,
              rank: 2,
              pedestalHeight: 90.h,
              pedestalColor: const Color(0xFFD6D1E3),
              rankColor: const Color(0xFF8F88A6),
              avatarBorderColor: const Color(0xFFAFA7C5),
            ),
          ),
          SizedBox(width: 8.w),

          // 1st Place (Center - Tallest)
          Expanded(
            child: _buildPodiumColumn(
              student: rank1,
              rank: 1,
              pedestalHeight: 120.h,
              pedestalColor: const Color(0xFFFFD566),
              rankColor: const Color(0xFFD49C14),
              avatarBorderColor: const Color(0xFFFBC841),
              hasCrown: true,
            ),
          ),
          SizedBox(width: 8.w),

          // 3rd Place (Right)
          Expanded(
            child: _buildPodiumColumn(
              student: rank3,
              rank: 3,
              pedestalHeight: 70.h,
              pedestalColor: const Color(0xFFE8BCA0),
              rankColor: const Color(0xFFB57E5A),
              avatarBorderColor: const Color(0xFFD49A75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required LeaderboardItemModel student,
    required int rank,
    required double pedestalHeight,
    required Color pedestalColor,
    required Color rankColor,
    required Color avatarBorderColor,
    bool hasCrown = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown for 1st place
        if (hasCrown)
          Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: const Color(0xFFF9A825),
              size: 26.sp,
            ),
          )
        else
          SizedBox(height: 28.h),

        // Avatar with rank badge
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 58.w,
              height: 58.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: avatarBorderColor, width: 2.5.w),
                color: AppColor.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
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
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: rankColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColor.white, width: 1.5.w),
              ),
              alignment: Alignment.center,
              child: Text(
                '$rank',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 6.h),

        // Student Name
        Text(
          student.nickname,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.nunito(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: AppColor.secondary,
          ),
        ),

        SizedBox(height: 4.h),

        // Points Chip
        PointsChip(count: student.kindnessPoints),

        SizedBox(height: 8.h),

        // Pedestal block with Rank Number
        Container(
          height: pedestalHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: pedestalColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '$rank',
            style: GoogleFonts.nunito(
              fontSize: 36.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    );
  }

  Widget _defaultAvatar() {
    return Assets.characters.heroSamantha.image(
      fit: BoxFit.cover,
    );
  }
}
