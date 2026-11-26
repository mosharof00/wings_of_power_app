import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/achievement_models.dart';

class LeaderboardAvatar extends StatelessWidget {
  const LeaderboardAvatar({
    super.key,
    required this.student,
    required this.size,
    required this.color,
    this.outlined = false,
  });

  final LeaderboardItemModel student;
  final double size;
  final Color color;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final avatar = student.avatarUrl?.trim() ?? '';
    final uri = Uri.tryParse(avatar);
    final fallback = Center(
      child: Icon(
        Icons.person_rounded,
        size: size * 0.55,
        color: AppColor.secondary,
      ),
    );
    final Widget image;
    if (uri?.scheme == 'https' || uri?.scheme == 'http') {
      image = Image.network(
        avatar,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    } else if (avatar.startsWith('assets/')) {
      image = Image.asset(
        avatar,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    } else {
      image = fallback;
    }

    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: outlined
              ? Border.all(color: const Color(0xFF8AC6F6), width: 2.w)
              : null,
        ),
        child: ClipOval(child: image),
      ),
    );
  }
}

class LeaderboardScore extends StatelessWidget {
  const LeaderboardScore({
    super.key,
    required this.points,
    this.onPodium = false,
  });

  final int points;
  final bool onPodium;

  @override
  Widget build(BuildContext context) {
    final score = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    ).format(points);
    return Semantics(
      label: '$score kindness points',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: onPodium ? const Color(0xFFE6DCEF) : null,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: onPodium
              ? const [
                  BoxShadow(color: Color(0xFFB7ACCA), offset: Offset(0, 2)),
                ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: onPodium ? 8.w : 0,
            vertical: onPodium ? 2.w : 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  score,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: onPodium ? 15.sp : 14.sp,
                    fontWeight: FontWeight.w800,
                    color: onPodium
                        ? const Color(0xFF4C277F)
                        : AppColor.secondary,
                  ),
                ),
              ),
              SizedBox(width: onPodium ? 5.w : 7.w),
              Image.asset(
                'assets/images/leaderboard_coin.png',
                width: onPodium ? 11.w : 18.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
