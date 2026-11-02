import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';

class ReadingProgressSummaryCard extends StatelessWidget {
  const ReadingProgressSummaryCard({
    super.key,
    required this.overallPercent,
    required this.statusMessage,
    required this.storiesCompleted,
    required this.storiesTotal,
    required this.quizScoreMean,
    required this.streakDays,
  });

  final int overallPercent;
  final String statusMessage;
  final int storiesCompleted;
  final int storiesTotal;
  final int quizScoreMean;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Progress Indicator
          SizedBox(
            width: 120.w,
            height: 120.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 110.w,
                  height: 110.w,
                  child: CircularProgressIndicator(
                    value: overallPercent / 100.0,
                    strokeWidth: 10.w,
                    backgroundColor: const Color(0xFFFDEEE5),
                    color: AppColor.primary,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$overallPercent%',
                      style: GoogleFonts.nunito(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColor.secondary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      statusMessage,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.subtitle,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // 3 Stat Boxes Row
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  value: '$storiesCompleted/$storiesTotal',
                  label: 'Stories Read',
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildStatTile(
                  value: '$quizScoreMean%',
                  label: 'Quiz Score',
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildStatTile(
                  value: '$streakDays days',
                  label: 'Day Streak',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({required String value, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7FC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColor.chip.withValues(alpha: 0.6),
          width: 1.w,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: AppColor.secondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.subtitle,
            ),
          ),
        ],
      ),
    );
  }
}
