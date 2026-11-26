import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/achievement_models.dart';

import 'leaderboard_identity.dart';

class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({super.key, required this.student});

  final LeaderboardItemModel student;

  static const _avatarColors = [
    Color(0xFFFFCFAD),
    Color(0xFFAAA8FA),
    Color(0xFF91C2F5),
    Color(0xFF8BD18F),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 58.w),
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 10.w),
      decoration: BoxDecoration(
        color: student.isCurrentStudent || student.rank == 4
            ? const Color(0xFFFCE9DD)
            : const Color(0xFFFCF9EE),
        borderRadius: BorderRadius.circular(10.r),
        border: student.isCurrentStudent
            ? Border.all(color: const Color(0xFFDC864B))
            : null,
      ),
      child: Row(
        children: [
          Text(
            '#${student.rank}',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF494956)),
          ),
          SizedBox(width: 8.w),
          LeaderboardAvatar(
            student: student,
            size: 36.w,
            color: _avatarColors[(student.rank - 4) % _avatarColors.length],
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              student.nickname,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: AppColor.secondary,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(child: LeaderboardScore(points: student.kindnessPoints)),
        ],
      ),
    );
  }
}
