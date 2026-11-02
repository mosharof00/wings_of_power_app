import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/error_block.dart';
import 'package:wings_of_power_app/app/global/widgets/global_loading.dart';
import 'package:wings_of_power_app/app/global/widgets/points_chip.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

import '../controllers/achievements_controller.dart';
import 'widgets/badge_card.dart';

class BadgesView extends GetView<AchievementsController> {
  const BadgesView({super.key, this.isEmbeddedInNav = false});

  final bool isEmbeddedInNav;

  @override
  Widget build(BuildContext context) {
    final showBackButton = !isEmbeddedInNav && Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: AppColor.background,
      body: Stack(
        children: [
          // Sky & clouds background banner
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),

                // Top Header Row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      if (showBackButton) ...[
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
                        SizedBox(width: 12.w),
                      ],
                      Expanded(
                        child: Text(
                          'Badges & Achievements',
                          textAlign: showBackButton ? TextAlign.left : TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColor.secondary,
                          ),
                        ),
                      ),
                      if (showBackButton) SizedBox(width: 44.w),
                    ],
                  ),
                ),

                SizedBox(height: 14.h),

                // Subheader: Earned count + Points Chip
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${controller.earnedCount.value} of ${controller.totalCount.value} badges earned',
                          style: GoogleFonts.nunito(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.subtitle,
                          ),
                        ),
                        PointsChip(count: controller.points.value),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 14.h),

                // Badges Grid
                Expanded(
                  child: Obx(() {
                    if (controller.isBadgesLoading.value) {
                      return const Center(child: GlobalLoading());
                    }

                    if (controller.badgesError.value.isNotEmpty) {
                      return Center(
                        child: ErrorBlock(
                          message: controller.badgesError.value,
                          onRetry: controller.fetchBadges,
                        ),
                      );
                    }

                    final badgesList = controller.badges;

                    return RefreshIndicator(
                      onRefresh: controller.fetchBadges,
                      color: AppColor.primary,
                      child: GridView.builder(
                        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 90.h),
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14.w,
                          mainAxisSpacing: 14.h,
                          childAspectRatio: 0.88,
                        ),
                        itemCount: badgesList.length,
                        itemBuilder: (context, index) {
                          final badge = badgesList[index];
                          return BadgeCard(
                            badge: badge,
                            onTap: () => controller.onBadgeTap(context, badge),
                          );
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
