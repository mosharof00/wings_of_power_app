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
import 'widgets/leaderboard_podium.dart';
import 'widgets/leaderboard_row.dart';

class LeaderboardView extends GetView<AchievementsController> {
  const LeaderboardView({super.key});

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
                        'Leaderboard',
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

                SizedBox(height: 10.h),

                // Content
                Expanded(
                  child: Obx(() {
                    if (controller.isLeaderboardLoading.value) {
                      return const Center(child: GlobalLoading());
                    }

                    if (controller.leaderboardError.value.isNotEmpty) {
                      return Center(
                        child: ErrorBlock(
                          message: controller.leaderboardError.value,
                          onRetry: () => controller.fetchLeaderboard(),
                        ),
                      );
                    }

                    final podiumList = controller.podium;
                    final rows = controller.rankedList;

                    if (podiumList.isEmpty && rows.isEmpty) {
                      return Center(
                        child: ShowEmptyResult(
                          title: 'No leaderboard data',
                          desc: 'Earn kindness points to place on the leaderboard!',
                          refreshOnTap: () => controller.fetchLeaderboard(),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => controller.fetchLeaderboard(),
                      color: AppColor.primary,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          // Top 3 Podium
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
                              child: LeaderboardPodium(podium: podiumList),
                            ),
                          ),

                          // Ranked List (4+)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 30.h),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final student = rows[index];
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 10.h),
                                    child: LeaderboardRow(student: student),
                                  );
                                },
                                childCount: rows.length,
                              ),
                            ),
                          ),
                        ],
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
