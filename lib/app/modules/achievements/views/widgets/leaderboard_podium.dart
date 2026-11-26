import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/achievement_models.dart';

import 'leaderboard_identity.dart';

class LeaderboardPodium extends StatelessWidget {
  const LeaderboardPodium({super.key, required this.podium});

  final List<LeaderboardItemModel> podium;

  @override
  Widget build(BuildContext context) {
    if (podium.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final index in [1, 0, 2])
            Expanded(
              child: index < podium.length
                  ? _PodiumPlace(student: podium[index], position: index)
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({required this.student, required this.position});

  final LeaderboardItemModel student;
  final int position;

  @override
  Widget build(BuildContext context) {
    final (height, color, avatarColor) = switch (position) {
      0 => (216.0, const Color(0xFF8BD18F), const Color(0xFFFFCFAD)),
      1 => (178.0, const Color(0xFFAAA8FA), const Color(0xFFFFF4DB)),
      _ => (150.0, const Color(0xFF91C2F5), const Color(0xFFEEE8F3)),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LeaderboardAvatar(
          student: student,
          size: 80.w,
          color: avatarColor,
          outlined: true,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(4.w, 6.w, 4.w, 6.w),
          child: Text(
            student.nickname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColor.secondary,
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: LeaderboardScore(
            points: student.kindnessPoints,
            onPodium: true,
          ),
        ),
        SizedBox(height: 10.w),
        ClipPath(
          clipper: const _PedestalTop(),
          child: Container(
            width: double.infinity,
            height: 29.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.lerp(color, Colors.white, 0.48)!, color],
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: height.w,
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: 14.w),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1.5.w),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color, Color.lerp(color, Colors.white, 0.34)!],
              stops: const [0, 0.88, 1],
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${student.rank}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 56.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PedestalTop extends CustomClipper<Path> {
  const _PedestalTop();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width * 0.08, 0)
    ..lineTo(size.width * 0.92, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(_PedestalTop oldClipper) => false;
}
