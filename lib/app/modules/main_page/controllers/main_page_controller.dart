import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wings_of_power_app/app/core/utils/dialog_utils.dart';
import 'package:get/get.dart';

class MainPageController extends GetxController {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final selectedIndex = 0.obs;

  bool _isExitDialogOpen = false;

  void changePage(int index) => selectedIndex.value = index;

  /// Home, stories, badges, and profile switch the shell tab.
  /// Basketball is drawn on the bar so it matches the screenshot. Opening the
  /// game is `docs/game/tasks/T-GAME-001`; this tap stays empty.
  void onNavTap(int index) {
    if (index == 2) return;
    changePage(index);
  }

  /// Hardware/gesture back on the main page: close the drawer if one is open,
  /// otherwise confirm before exiting the app.
  void onBackPressed() {
    if (scaffoldKey.currentState?.isDrawerOpen ?? false) {
      scaffoldKey.currentState?.closeDrawer();
      return;
    }
    if (_isExitDialogOpen) return;
    _isExitDialogOpen = true;

    DialogUtils.showDialog(
      context: Get.context!,
      dialogType: DialogType.question,
      title: 'Exit App',
      description: 'Are you sure you want to exit the app?',
      okText: 'Exit',
      cancelText: 'Cancel',
      okOnPress: SystemNavigator.pop,
      cancelOnPress: () {},
      onDismiss: () => _isExitDialogOpen = false,
    );
  }
}
