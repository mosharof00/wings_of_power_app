import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/custom_icon_button.dart';
import '../controllers/safe_space_controller.dart';
import '../widgets/safe_space_report_card.dart';

class SafeSpaceReportsListView extends GetView<SafeSpaceController> {
  const SafeSpaceReportsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC3EAFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Bar ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  CustomIconButton(
                    onPressed: () => Get.back(),
                    size: 40.w,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'My Reports',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.secondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 40.w), // Balance back button
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // ── Privacy Header ───────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Privacy Matters',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE65100),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Your reports are only visible to authorized school staff.',
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      color: AppColor.subtitle,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),

            // ── Filter Chips ─────────────────────────────────────────
            SizedBox(
              height: 40.h,
              child: Obx(() {
                final currentFilter = controller.selectedFilter.value;
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  children: [
                    _buildFilterChip('All Reports', 'ALL', currentFilter),
                    SizedBox(width: 10.w),
                    _buildFilterChip('New', 'NEW', currentFilter),
                    SizedBox(width: 10.w),
                    _buildFilterChip('Reviewing', 'REVIEWING', currentFilter),
                    SizedBox(width: 10.w),
                    _buildFilterChip('Addressed', 'ADDRESSED', currentFilter),
                  ],
                );
              }),
            ),
            SizedBox(height: 16.h),

            // ── Reports List ─────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoadingReports.value &&
                    controller.reports.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = controller.filteredReports;
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 56.sp,
                            color: const Color(0x808A8C92),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'No reports found',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColor.subtitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchReports(),
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final report = list[index];
                      return SafeSpaceReportCard(
                        report: report,
                        onTap: () => controller.openReportDetail(report),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String currentFilter) {
    final isSelected = currentFilter.toUpperCase() == value.toUpperCase();
    return InkWell(
      onTap: () => controller.setFilter(value),
      borderRadius: BorderRadius.circular(20.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColor.secondary,
          ),
        ),
      ),
    );
  }
}
