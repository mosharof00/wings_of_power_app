import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/safe_space_models.dart';

class SafeSpaceReportCard extends StatelessWidget {
  final SafeSpaceReportModel report;
  final VoidCallback onTap;

  const SafeSpaceReportCard({
    super.key,
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    report.category,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColor.secondary,
                      height: 1.25,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                _buildStatusPill(report.status),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              report.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.subtitle,
                height: 1.3,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14.sp,
                  color: AppColor.subtitle,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    'Submitted On: ${report.shortSubmittedDate}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColor.subtitle,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 20.sp,
                  color: AppColor.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    final s = status.toUpperCase();
    Color bg;
    Color border;
    Color text;
    String label;

    switch (s) {
      case 'REVIEWING':
        bg = const Color(0xFFFFF8E1);
        border = const Color(0xFFFFE082);
        text = const Color(0xFFF57C00);
        label = 'Reviewing';
        break;
      case 'ADDRESSED':
        bg = const Color(0xFFE8F5E9);
        border = const Color(0xFFA5D6A7);
        text = const Color(0xFF388E3C);
        label = 'Addressed';
        break;
      case 'NEW':
      default:
        bg = const Color(0xFFE3F2FD);
        border = const Color(0xFF90CAF9);
        text = const Color(0xFF1976D2);
        label = 'New';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}
