import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/extensions/text_style_extension.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/student_bottom_nav.dart';

import '../../home/views/home_view.dart';
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
        body: Obx(() {
          final index = controller.selectedIndex.value;
          return IndexedStack(
            index: _bodyIndex(index),
            children: const [
              HomeView(),
              _ShellTab('Stories'),
              _ShellTab('Badges'),
              _ShellTab('Profile'),
            ],
          );
        }),
        bottomNavigationBar: Obx(
          () => StudentBottomNav(
            selectedIndex: controller.selectedIndex.value,
            onTap: controller.onNavTap,
          ),
        ),
      ),
    );
  }

  /// Nav index 2 is the basketball icon and is never selected.
  int _bodyIndex(int navIndex) {
    if (navIndex <= 1) return navIndex;
    if (navIndex == 3) return 2;
    return 3;
  }
}

class _ShellTab extends StatelessWidget {
  const _ShellTab(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: context.headlineLarge),
    );
  }
}
