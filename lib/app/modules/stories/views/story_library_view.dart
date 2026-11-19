import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/story_models.dart';
import 'package:wings_of_power_app/app/global/widgets/app_scaffold.dart';
import 'package:wings_of_power_app/app/global/widgets/error_block.dart';
import 'package:wings_of_power_app/app/global/widgets/global_loading.dart';
import 'package:wings_of_power_app/app/global/widgets/search_field.dart';
import 'package:wings_of_power_app/app/global/widgets/show_empty_result.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

import '../controllers/stories_controller.dart';
import 'widgets/filter_dropdown_pill.dart';
import 'widgets/story_cover_card.dart';
import 'widgets/story_section_row.dart';

class StoryLibraryView extends GetView<StoriesController> {
  const StoryLibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Stack(
        children: [
          Positioned(
            top: 10,
            left: -10,
            right: -10,
            child: Assets.backgrounds.bgHomeSky.image(fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: controller.onBack,
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
                      Expanded(
                        child: Text(
                          'Story Library',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColor.secondary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.toggleSearch,
                        child: Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: const BoxDecoration(
                            color: AppColor.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.search_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                  child: SearchField(
                    controller: controller.searchController,
                    hintText: 'Search stories...',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Obx(
                    () => Row(
                      children: [
                        FilterDropdownPill(
                          selectedLabel: controller.selectedCategoryLabel.value,
                          sheetTitle: 'Select Category',
                          options: controller.categoryFilterOptions,
                          onSelected: controller.setCategoryLabel,
                        ),
                        SizedBox(width: 12.w),
                        FilterDropdownPill(
                          selectedLabel:
                              controller.selectedAgeGroupLabel.value,
                          sheetTitle: 'Select Age Group',
                          options: StoriesController.ageGroupLabels,
                          onSelected: controller.setAgeGroupLabel,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: GlobalLoading());
                    }
                    if (controller.errorMessage.value.isNotEmpty) {
                      return Center(
                        child: ErrorBlock(
                          message: controller.errorMessage.value,
                          onRetry: controller.loadLibrary,
                        ),
                      );
                    }
                    if (controller.stories.isEmpty) {
                      return Center(
                        child: ShowEmptyResult(
                          title: 'No stories found',
                          desc:
                              'Try adjusting your filters or search keywords.',
                          refreshOnTap: controller.fetchStories,
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: controller.loadLibrary,
                      color: AppColor.primary,
                      child: _buildStoryContent(controller.stories.toList()),
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

  Widget _buildStoryContent(List<StorySummaryModel> allStories) {
    final isCategoryFiltered =
        controller.selectedCategoryLabel.value != 'All Category';
    final isAgeFiltered =
        controller.selectedAgeGroupLabel.value != 'All Age Group';

    if (isCategoryFiltered && isAgeFiltered) {
      return GridView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 90.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14.h,
          crossAxisSpacing: 14.w,
          childAspectRatio: 0.82,
        ),
        itemCount: allStories.length,
        itemBuilder: (context, index) {
          final story = allStories[index];
          return StoryCoverCard(
            story: story,
            onTap: () => controller.openStoryDetail(story.id),
          );
        },
      );
    }

    if (isCategoryFiltered) {
      final band6 = controller.storiesForAgeBand('AGE_6_9');
      final band10 = controller.storiesForAgeBand('AGE_10_13');
      final bandAdults = controller.storiesForAgeBand('ADULTS');

      return ListView(
        padding: EdgeInsets.only(bottom: 90.h),
        children: [
          StorySectionRow(
            title: 'Books for 6 to 9 Year-Olds',
            stories: band6,
            onSeeAll: () => controller.setAgeGroupLabel('Age 6 to 9'),
            onStoryTap: (s) => controller.openStoryDetail(s.id),
          ),
          SizedBox(height: 18.h),
          StorySectionRow(
            title: 'Books for 10 to 13 Year-Olds',
            stories: band10,
            onSeeAll: () => controller.setAgeGroupLabel('Age 10 to 13'),
            onStoryTap: (s) => controller.openStoryDetail(s.id),
          ),
          SizedBox(height: 18.h),
          StorySectionRow(
            title: 'Books for Adults',
            stories: bandAdults,
            onSeeAll: () => controller.setAgeGroupLabel('Adults'),
            onStoryTap: (s) => controller.openStoryDetail(s.id),
          ),
        ],
      );
    }

    final sections = controller.themeSections;
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 90.h),
      itemCount: sections.length,
      separatorBuilder: (_, _) => SizedBox(height: 18.h),
      itemBuilder: (context, index) {
        final section = sections[index];
        return StorySectionRow(
          title: section.theme.name,
          stories: section.stories,
          onSeeAll: () => controller.setCategoryLabel(section.theme.name),
          onStoryTap: (s) => controller.openStoryDetail(s.id),
        );
      },
    );
  }
}
