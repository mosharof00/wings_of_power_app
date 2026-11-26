import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/app_scaffold.dart';
import 'package:wings_of_power_app/app/global/widgets/app_sunburst_background.dart';
import 'package:wings_of_power_app/app/global/widgets/error_block.dart';
import 'package:wings_of_power_app/app/global/widgets/global_loading.dart';
import 'package:wings_of_power_app/app/global/widgets/show_empty_result.dart';

import '../controllers/achievements_controller.dart';
import 'widgets/leaderboard_podium.dart';
import 'widgets/leaderboard_row.dart';

class LeaderboardView extends GetView<AchievementsController> {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(
            color: Color(0xFFB3E4FA),
            child: CustomPaint(
              painter: AppSunburstPainter(
                centerAlignment: Alignment(0, -0.1),
                rayCount: 20,
                rayColor: Color(0xFF9FDBF5),
                secondaryRayColor: Color(0xFFB9E9FA),
              ),
              child: SizedBox.expand(),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 5.w, 20.w, 0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44.w,
                        height: 44.w,
                        child: IconButton(
                          tooltip: MaterialLocalizations.of(context)
                              .backButtonTooltip,
                          onPressed: () => Get.back<void>(),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF17C32),
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: const Color(0xFFD26928),
                              width: 2.w,
                            ),
                          ),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Leaderboard',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 23.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColor.secondary,
                          ),
                        ),
                      ),
                      SizedBox(width: 44.w),
                    ],
                  ),
                ),
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

                    final podium = controller.podium;
                    final rows = controller.rankedList;
                    if (podium.isEmpty && rows.isEmpty) {
                      return Center(
                        child: ShowEmptyResult(
                          title: 'No leaderboard data',
                          desc: 'Earn kindness points to place on the leaderboard!',
                          refreshOnTap: () => controller.fetchLeaderboard(),
                        ),
                      );
                    }

                    final bottom = MediaQuery.paddingOf(context).bottom;
                    return RefreshIndicator(
                      onRefresh: () => controller.fetchLeaderboard(),
                      color: AppColor.primary,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.only(top: 24.w),
                            sliver: SliverToBoxAdapter(
                              child: LeaderboardPodium(podium: podium),
                            ),
                          ),
                          if (rows.isNotEmpty)
                            DecoratedSliver(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFEFD),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(32.r),
                                ),
                              ),
                              sliver: SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  16.w,
                                  16.w,
                                  16.w,
                                  16.w + bottom,
                                ),
                                sliver: SliverList.separated(
                                  itemCount: rows.length,
                                  itemBuilder: (context, index) =>
                                      LeaderboardRow(student: rows[index]),
                                  separatorBuilder: (context, index) =>
                                      SizedBox(height: 16.w),
                                ),
                              ),
                            )
                          else
                            SliverToBoxAdapter(
                              child: SizedBox(height: bottom + 16.w),
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
