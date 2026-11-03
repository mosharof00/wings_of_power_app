import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GameVoteWaitingOverlay extends StatelessWidget {
  const GameVoteWaitingOverlay({
    super.key,
    this.submittedCount,
    this.teamSize,
    this.isOtherTeam = false,
    this.teamLabel,
  });

  final int? submittedCount;
  final int? teamSize;
  final bool isOtherTeam;
  final String? teamLabel;

  @override
  Widget build(BuildContext context) {
    final title = isOtherTeam
        ? '${teamLabel ?? "Other Team"} is Voting'
        : 'Waiting for your classmates';
    final subtitle = isOtherTeam
        ? 'Please wait for the result!'
        : 'One of your classmates is still thinking';

    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 44.w,
                  height: 44.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 3.5,
                    color: Color(0xFFE86726),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                if (submittedCount != null && teamSize != null && teamSize! > 0) ...[
                  SizedBox(height: 14.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Votes cast: $submittedCount / $teamSize',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

