import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/home_models.dart';
import 'package:wings_of_power_app/app/global/widgets/error_block.dart';
import 'package:wings_of_power_app/app/global/widgets/global_loading.dart';
import 'package:wings_of_power_app/app/global/widgets/search_field.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

import '../controllers/home_controller.dart';
import 'widgets/home_banner_card.dart';
import 'widgets/home_categories_carousel.dart';
import 'widgets/home_explore_more_section.dart';
import 'widgets/home_header.dart';
import 'widgets/home_play_game_banner.dart';
import 'widgets/home_popular_stories_section.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Stack(
        children: [
          // Fluffy sky clouds background at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Assets.backgrounds.bgHomeSky.image(
              fit: BoxFit.fill,
              height: 110.h,
            ),
          ),
          SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: GlobalLoading());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: ErrorBlock(
                    message: controller.errorMessage.value,
                    onRetry: controller.fetchHome,
                  ),
                );
              }

              final data = controller.homeData.value;
              if (data == null) {
                return Center(
                  child: ErrorBlock(
                    message: 'No home data available',
                    onRetry: controller.fetchHome,
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchHome,
                color: AppColor.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      // Top header: Greeting, points chip, bell icon
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: HomeHeader(
                          greeting: controller.greeting,
                          subtitle: controller.subtitle,
                          points: controller.points,
                          avatarUrl: controller.avatarUrl,
                          onBellTap: controller.onBellTap,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Search pill
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: SearchField(
                          controller: controller.searchController,
                          hintText: 'Search',
                          onChanged: (val) =>
                              controller.searchQuery.value = val.trim(),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Dynamic Banner (Start Reading / Continue / Quiz)
                      if (controller.banner != null) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: HomeBannerCard(
                            banner: controller.banner!,
                            onAction: _handleBannerAction,
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                      // Categories Carousel
                      HomeCategoriesCarousel(
                        categories: controller.categories,
                        onCategoryTap: controller.onCategoryTap,
                      ),
                      SizedBox(height: 20.h),
                      // Popular Stories grid (locally filtered on search)
                      HomePopularStoriesSection(
                        stories: controller.filteredPopularStories,
                        onSeeAll: controller.onSeeAllStories,
                        onStoryTap: controller.onStoryTap,
                      ),
                      SizedBox(height: 20.h),
                      // Ready to Take the Shot? Banner
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: HomePlayGameBanner(
                          onPlayGame: controller.onPlayGame,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // Explore More circles
                      HomeExploreMoreSection(
                        onKindnessCornerTap: controller.onKindnessCornerTap,
                        onAudioBooksTap: controller.onAudioBooksTap,
                        onSafeSpaceReportTap: controller.onSafeSpaceReport,
                      ),
                      // Bottom bar clearance
                      SizedBox(height: 96.h),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _handleBannerAction() {
    final banner = controller.banner;
    if (banner == null) return;
    switch (banner.type) {
      case HomeBannerType.startReading:
        controller.onStartReading();
        break;
      case HomeBannerType.continueReading:
        controller.onContinueReading();
        break;
      case HomeBannerType.quiz:
        controller.onTakeQuiz();
        break;
    }
  }
}
