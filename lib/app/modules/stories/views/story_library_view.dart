import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/story_models.dart';
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                // Header: Back button, Title, Search button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
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

                      // Title
                      Text(
                        'Story Library',
                        style: GoogleFonts.nunito(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColor.secondary,
                        ),
                      ),

                      // Search Button
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

                // Search field (shown when toggled or search query exists)
                Obx(() {
                  if (!controller.isSearchOpen.value &&
                      controller.searchQuery.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                    child: SearchField(
                      controller: controller.searchController,
                      hintText: 'Search stories...',
                      onChanged: (val) => controller.searchQuery.value = val.trim(),
                    ),
                  );
                }),

                // Filter Dropdowns Row: Category & Age Group
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Obx(
                    () => Row(
                      children: [
                        FilterDropdownPill(
                          selectedLabel: controller.selectedCategory.value,
                          sheetTitle: 'Select Category',
                          options: StoriesController.categories,
                          onSelected: controller.setCategory,
                        ),
                        SizedBox(width: 12.w),
                        FilterDropdownPill(
                          selectedLabel: controller.selectedAgeGroup.value,
                          sheetTitle: 'Select Age Group',
                          options: StoriesController.ageGroups,
                          onSelected: controller.setAgeGroup,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 14.h),

                // Content Area
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: GlobalLoading());
                    }

                    if (controller.errorMessage.value.isNotEmpty) {
                      return Center(
                        child: ErrorBlock(
                          message: controller.errorMessage.value,
                          onRetry: controller.fetchStories,
                        ),
                      );
                    }

                    final storiesList = controller.stories;

                    if (storiesList.isEmpty) {
                      return Center(
                        child: ShowEmptyResult(
                          title: 'No stories found',
                          desc: 'Try adjusting your filters or search keywords.',
                          refreshOnTap: controller.fetchStories,
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: controller.fetchStories,
                      color: AppColor.primary,
                      child: _buildStoryContent(storiesList),
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
        controller.selectedCategory.value != 'All Category';
    final isAgeFiltered =
        controller.selectedAgeGroup.value != 'All Age Group';

    // State 3: Both Category and Age Group are filtered -> 2-Column Grid
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

    // State 2: Category filtered, All Age Groups -> Group by Age Band
    if (isCategoryFiltered) {
      final stories6To9 = allStories.where((s) {
        final ag = s.ageGroup.toLowerCase();
        return ag.contains('6') || s.id.contains('golden-pearl');
      }).toList();

      final stories10To13 = allStories.where((s) {
        final ag = s.ageGroup.toLowerCase();
        return ag.contains('10') || s.id.contains('city-of-thieves');
      }).toList();

      final storiesAdults = allStories.where((s) {
        final ag = s.ageGroup.toLowerCase();
        return ag.contains('adult') || ag.contains('14') || s.id.contains('ties-that-bind');
      }).toList();

      return ListView(
        padding: EdgeInsets.only(bottom: 90.h),
        children: [
          StorySectionRow(
            title: 'Books for 6 to 9 Year-Olds',
            stories: stories6To9.isNotEmpty ? stories6To9 : allStories,
            onSeeAll: () => controller.setAgeGroup('Age 6 to 9'),
            onStoryTap: (s) => controller.openStoryDetail(s.id),
          ),
          SizedBox(height: 18.h),
          StorySectionRow(
            title: 'Books for 10 to 13 Year-Olds',
            stories: stories10To13.isNotEmpty ? stories10To13 : allStories,
            onSeeAll: () => controller.setAgeGroup('Age 10 to 13'),
            onStoryTap: (s) => controller.openStoryDetail(s.id),
          ),
          SizedBox(height: 18.h),
          StorySectionRow(
            title: 'Books for 14+',
            stories: storiesAdults.isNotEmpty ? storiesAdults : allStories,
            onSeeAll: () => controller.setAgeGroup('Adults'),
            onStoryTap: (s) => controller.openStoryDetail(s.id),
          ),
        ],
      );
    }

    // State 1: All Categories -> Group by Category
    final kindnessStories = allStories.where((s) {
      final c = s.category.toLowerCase();
      return c == 'kindness' || s.id.contains('golden-pearl');
    }).toList();

    final courageStories = allStories.where((s) {
      final c = s.category.toLowerCase();
      return c == 'courage' || s.id.contains('golden-pearl');
    }).toList();

    final cyberStories = allStories.where((s) {
      final c = s.category.toLowerCase();
      return c == 'cyberbullying' || s.id.contains('city-of-thieves');
    }).toList();

    final friendshipStories = allStories.where((s) {
      final c = s.category.toLowerCase();
      return c == 'friendship' || s.id.contains('ties-that-bind');
    }).toList();

    return ListView(
      padding: EdgeInsets.only(bottom: 90.h),
      children: [
        StorySectionRow(
          title: 'Kindness',
          stories: kindnessStories,
          onSeeAll: () => controller.setCategory('Kindness'),
          onStoryTap: (s) => controller.openStoryDetail(s.id),
        ),
        SizedBox(height: 18.h),
        StorySectionRow(
          title: 'Courage',
          stories: courageStories.isNotEmpty ? courageStories : kindnessStories,
          onSeeAll: () => controller.setCategory('Courage'),
          onStoryTap: (s) => controller.openStoryDetail(s.id),
        ),
        SizedBox(height: 18.h),
        StorySectionRow(
          title: 'Cyberbullying',
          stories: cyberStories.isNotEmpty ? cyberStories : allStories,
          onSeeAll: () => controller.setCategory('Cyberbullying'),
          onStoryTap: (s) => controller.openStoryDetail(s.id),
        ),
        SizedBox(height: 18.h),
        StorySectionRow(
          title: 'Friendship',
          stories: friendshipStories.isNotEmpty ? friendshipStories : allStories,
          onSeeAll: () => controller.setCategory('Friendship'),
          onStoryTap: (s) => controller.openStoryDetail(s.id),
        ),
      ],
    );
  }
}
