import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/safe_space_models.dart';

class SafeSpaceReportDetailSheet extends StatelessWidget {
  final SafeSpaceReportModel report;
  final VoidCallback onClose;

  const SafeSpaceReportDetailSheet({
    super.key,
    required this.report,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusPill(report.status),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.close_rounded,
                    size: 24.sp,
                    color: const Color(0xFFF5A87F),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Report Details',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColor.secondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Report ID: ${report.publicRef}',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4B3F72),
            ),
          ),
          SizedBox(height: 14.h),
          const Divider(
            color: Color(0xFFF1EBF5),
            thickness: 1.2,
            height: 1,
          ),
          SizedBox(height: 18.h),
          Text(
            'Concern Category',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColor.hintText,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            report.category,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.secondary,
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            'Date Submitted',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColor.hintText,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            report.longSubmittedDate,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.secondary,
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            'What Happened?',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColor.hintText,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            report.body.isNotEmpty ? report.body : 'No details provided.',
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColor.secondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 8.h),
        ],
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
