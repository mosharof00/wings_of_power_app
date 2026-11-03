import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GameVsPills extends StatelessWidget {
  const GameVsPills({
    super.key,
    required this.teamALabel,
    required this.teamAScore,
    required this.teamBLabel,
    required this.teamBScore,
    this.isTeamAActive = false,
    this.isTeamBActive = false,
  });

  final String teamALabel;
  final int teamAScore;
  final String teamBLabel;
  final int teamBScore;
  final bool isTeamAActive;
  final bool isTeamBActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          // Team A Pill
          Expanded(
            child: _buildPill(
              label: teamALabel,
              score: teamAScore,
              isActive: isTeamAActive,
            ),
          ),

          // VS separator
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Text(
              'Vs',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 4,
                    color: Color(0x66000000),
                  ),
                ],
              ),
            ),
          ),

          // Team B Pill
          Expanded(
            child: _buildPill(
              label: teamBLabel,
              score: teamBScore,
              isActive: isTeamBActive,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required int score,
    required bool isActive,
  }) {
    return Container(
      height: 72.h,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFFD54F) : const Color(0xFFFEF3DE),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isActive ? const Color(0xFFFFB300) : const Color(0xFFFFE0B2),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1E1B4B),
            ),
          ),
        ],
      ),
    );
  }
}
