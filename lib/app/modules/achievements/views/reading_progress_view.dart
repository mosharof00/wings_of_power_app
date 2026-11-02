import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/error_block.dart';
import 'package:wings_of_power_app/app/global/widgets/global_button.dart';
import 'package:wings_of_power_app/app/global/widgets/global_loading.dart';
import 'package:wings_of_power_app/app/global/widgets/show_empty_result.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

import '../controllers/achievements_controller.dart';
import 'widgets/chapter_progress_item.dart';
import 'widgets/reading_progress_card.dart';

class ReadingProgressView extends GetView<AchievementsController> {
  const ReadingProgressView({super.key});

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
                        'My Reading Progress',
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

                SizedBox(height: 12.h),

                // Progress Content
                Expanded(
                  child: Obx(() {
                    if (controller.isReadingProgressLoading.value) {
                      return const Center(child: GlobalLoading());
                    }

                    if (controller.readingProgressError.value.isNotEmpty) {
                      return Center(
                        child: ErrorBlock(
                          message: controller.readingProgressError.value,
                          onRetry: controller.fetchReadingProgress,
                        ),
                      );
                    }

                    final chapters = controller.chapterProgressList;

                    if (chapters.isEmpty) {
                      return Center(
                        child: ShowEmptyResult(
                          title: 'No reading progress',
                          desc: 'Start reading stories to track your progress!',
                          refreshOnTap: controller.fetchReadingProgress,
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: controller.fetchReadingProgress,
                      color: AppColor.primary,
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
                        children: [
                          // Top Summary Card
                          ReadingProgressSummaryCard(
                            overallPercent: controller.overallPercent.value,
                            statusMessage: controller.statusMessage.value,
                            storiesCompleted: controller.storiesCompleted.value,
                            storiesTotal: controller.storiesTotal.value,
                            quizScoreMean: controller.quizScoreMean.value,
                            streakDays: controller.streakDays.value,
                          ),

                          SizedBox(height: 16.h),

                          // Chapter items
                          for (final ch in chapters) ...[
                            ChapterProgressItem(chapter: ch),
                            SizedBox(height: 12.h),
                          ],
                        ],
                      ),
                    );
                  }),
                ),

                // Bottom CTA Button: Explore Stories
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                  child: GlobalButton(
                    text: 'Explore Stories',
                    onTap: controller.onExploreStories,
                    height: 50.h,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
