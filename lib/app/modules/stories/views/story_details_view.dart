import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/story_models.dart';
import 'package:wings_of_power_app/app/global/widgets/error_block.dart';
import 'package:wings_of_power_app/app/global/widgets/global_button.dart';
import 'package:wings_of_power_app/app/global/widgets/global_loading.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

import '../controllers/stories_controller.dart';
import 'widgets/chapter_list_item.dart';

class StoryDetailsView extends GetView<StoriesController> {
  const StoryDetailsView({super.key});

  Widget _buildCoverImage(StoryDetailModel story) {
    if (story.coverUrl != null && story.coverUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: story.coverUrl!,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(color: AppColor.cream),
        errorWidget: (_, _, _) => _fallbackCover(),
      );
    }
    if (story.assetPath != null && story.assetPath!.isNotEmpty) {
      return Image.asset(
        story.assetPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallbackCover(),
      );
    }
    return _fallbackCover();
  }

  Widget _fallbackCover() {
    return Container(
      color: AppColor.cream,
      alignment: Alignment.center,
      child: Icon(
        Icons.menu_book_rounded,
        size: 50.sp,
        color: AppColor.primary.withValues(alpha: 0.6),
      ),
    );
  }

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
            child: Obx(() {
              if (controller.isDetailLoading.value) {
                return const Center(child: GlobalLoading());
              }

              if (controller.detailErrorMessage.value.isNotEmpty) {
                return Center(
                  child: ErrorBlock(
                    message: controller.detailErrorMessage.value,
                    onRetry: () {
                      final storyId = controller.storyDetail.value?.id;
                      if (storyId != null) {
                        controller.fetchStoryDetail(storyId);
                      }
                    },
                  ),
                );
              }

              final story = controller.storyDetail.value;
              if (story == null) {
                return const Center(child: GlobalLoading());
              }

              return Column(
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
                          'Story Details',
                          style: GoogleFonts.nunito(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColor.secondary,
                          ),
                        ),
                        SizedBox(width: 44.w), // Balance back button
                      ],
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Top Book Card with Cover + Title + Author
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColor.cream,
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(
                          color: AppColor.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(14.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColor.primary,
                                  width: 2.w,
                                ),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: AspectRatio(
                                aspectRatio: 1.6,
                                child: _buildCoverImage(story),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            story.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColor.primary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Written By ${story.author}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColor.subtitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // White bottom card for Description and Chapters tabs
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 16.h),

                          // Segmented Tab Control: Description vs Chapters
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Container(
                              height: 46.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDEEE5),
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          controller.selectedDetailTab.value = 0,
                                      child: Obx(
                                        () {
                                          final isSelected = controller
                                                  .selectedDetailTab.value ==
                                              0;
                                          return Container(
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColor.primary
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(24.r),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Description',
                                              style: GoogleFonts.nunito(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w800,
                                                color: isSelected
                                                    ? Colors.white
                                                    : AppColor.primary,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          controller.selectedDetailTab.value = 1,
                                      child: Obx(
                                        () {
                                          final isSelected = controller
                                                  .selectedDetailTab.value ==
                                              1;
                                          return Container(
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColor.primary
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(24.r),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Chapters',
                                              style: GoogleFonts.nunito(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w800,
                                                color: isSelected
                                                    ? Colors.white
                                                    : AppColor.primary,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // Tab Content Area
                          Expanded(
                            child: Obx(() {
                              if (controller.selectedDetailTab.value == 0) {
                                return _buildDescriptionTab(story);
                              } else {
                                return _buildChaptersTab(story);
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab(StoryDetailModel story) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3 Info icons container: Kindness, 6 chapters, 10 min
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColor.chip.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoMetric(
                  icon: Icons.volunteer_activism_rounded,
                  label: story.category,
                ),
                _buildInfoMetric(
                  icon: Icons.menu_book_rounded,
                  label: '${story.chapterCount} chapters',
                ),
                _buildInfoMetric(
                  icon: Icons.hourglass_bottom_rounded,
                  label: '${story.estimatedMinutes} min',
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // About heading
          Text(
            'About ${story.title}',
            style: GoogleFonts.nunito(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColor.secondary,
            ),
          ),
          SizedBox(height: 8.h),

          // Description text
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                story.synopsis,
                style: GoogleFonts.nunito(
                  fontSize: 14.sp,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: AppColor.subtitle,
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // CTA Button: Start Reading / Continue Reading
          GlobalButton(
            text: story.isStarted ? 'Continue Reading' : 'Start Reading',
            onTap: story.isStarted
                ? controller.onContinueReading
                : controller.onStartReading,
            height: 50.h,
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildChaptersTab(StoryDetailModel story) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 30.h),
      itemCount: story.chapters.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final chapter = story.chapters[index];
        return ChapterListItem(
          chapter: chapter,
          onTap: () => controller.onChapterTap(chapter),
          onQuizTap: () => controller.onQuizTap(chapter),
        );
      },
    );
  }

  Widget _buildInfoMetric({required IconData icon, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: const BoxDecoration(
            color: Color(0xFFFDEEE5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColor.primary,
            size: 20.sp,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColor.secondary,
          ),
        ),
      ],
    );
  }
}
