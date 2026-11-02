import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/error_block.dart';
import 'package:wings_of_power_app/app/global/widgets/global_loading.dart';
import 'package:wings_of_power_app/app/global/widgets/show_empty_result.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

import '../controllers/achievements_controller.dart';
import 'widgets/point_ledger_item.dart';

class PositivePointsView extends GetView<AchievementsController> {
  const PositivePointsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Stack(
        children: [
          // Top Sky & Clouds Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Assets.backgrounds.bgHomeSky.image(
              fit: BoxFit.fill,
              height: 120.h,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 8.h),

                // Header: Back button + Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: const BoxDecoration(
                            color: AppColor.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      Text(
                        'Positive Points',
                        style: GoogleFonts.nunito(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColor.secondary,
                        ),
                      ),
                      SizedBox(width: 44.w),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Points summary card
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Obx(
                    () => Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: AppColor.cream,
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(
                          color: AppColor.primary.withValues(alpha: 0.3),
                          width: 1.5.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${controller.totalPoints.value} Points',
                            style: GoogleFonts.nunito(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColor.secondary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDEEE5),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Text(
                              '+${controller.todayPoints.value} Today',
                              style: GoogleFonts.nunito(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Points Ledger List
                Expanded(
                  child: Obx(() {
                    if (controller.isPointsLoading.value) {
                      return const Center(child: GlobalLoading());
                    }

                    if (controller.pointsError.value.isNotEmpty) {
                      return Center(
                        child: ErrorBlock(
                          message: controller.pointsError.value,
                          onRetry: controller.fetchPoints,
                        ),
                      );
                    }

                    final items = controller.pointItems;

                    if (items.isEmpty) {
                      return Center(
                        child: ShowEmptyResult(
                          title: 'No points earned yet',
                          desc: 'Read stories, answer quizzes, and participate to earn points!',
                          refreshOnTap: controller.fetchPoints,
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: controller.fetchPoints,
                      color: AppColor.primary,
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 30.h),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          return PointLedgerItem(item: items[index]);
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
