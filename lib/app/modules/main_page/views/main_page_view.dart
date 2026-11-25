import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/student_bottom_nav.dart';

import '../../achievements/views/badges_view.dart';
import '../../game/views/game_mode_select_view.dart';
import '../../home/views/home_view.dart';
import '../../profile/views/profile_view.dart';
import '../../stories/views/story_library_view.dart';
import '../controllers/main_page_controller.dart';

class MainPageView extends GetView<MainPageController> {
  const MainPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.onBackPressed();
      },
      child: Scaffold(
        backgroundColor: AppColor.background,
        extendBody: true,
        body: Obx(() {
          final index = controller.selectedIndex.value;
          return IndexedStack(
            index: index,
            children: [
              const HomeView(),
              const StoryLibraryView(),
              if (index == 2)
                const GameModeSelectView(embeddedInTab: true)
              else
                const SizedBox.shrink(),
              const BadgesView(isEmbeddedInNav: true),
              const ProfileView(),
            ],
          );
        }),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
          child: Obx(
            () => StudentBottomNav(
              selectedIndex: controller.selectedIndex.value,
              onTap: controller.onNavTap,
            ),
          ),
        ),
      ),
    );
  }
}
