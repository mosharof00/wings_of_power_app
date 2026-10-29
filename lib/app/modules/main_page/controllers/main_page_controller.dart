import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wings_of_power_app/app/core/utils/dialog_utils.dart';
import 'package:wings_of_power_app/app/modules/products/views/products_view.dart';
import 'package:get/get.dart';

import '../../home/views/home_view.dart';
import '../../profile/views/profile_view.dart';

class MainPageController extends GetxController {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final selectedIndex = 0.obs;

  final List<Widget> pages = const [HomeView(), ProductsView(), ProfileView()];

  void changePage(int index) => selectedIndex.value = index;

  bool _isExitDialogOpen = false;

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
