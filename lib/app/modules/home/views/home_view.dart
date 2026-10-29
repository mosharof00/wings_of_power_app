import 'package:flutter/material.dart';
import 'package:wings_of_power_app/app/core/config/app_config.dart';
import 'package:wings_of_power_app/app/core/extensions/sizedbox_extension.dart';
import 'package:wings_of_power_app/app/core/extensions/text_style_extension.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/app_text.dart';
import 'package:wings_of_power_app/app/global/widgets/appbar_title.dart';
import 'package:wings_of_power_app/app/global/widgets/cached_image.dart';
import 'package:wings_of_power_app/app/global/widgets/shimmer_loading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle("Home"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: controller.onAuthAction,
            icon: Icon(
              controller.isLoggedIn ? Icons.logout : Icons.login,
              color: AppColor.primary,
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (controller.isLoggedIn) ...[
            const _UserHeader(),
            24.height,
          ],
          Center(child: Image.asset(AppConfig.appLogo, width: 200.w,)),

          20.height,
          AppText(
            "Welcome to Flutter Boilerplate with GetX CLI\n by Mosharof Khan",
            style: context.titleMedium.copyWith(fontSize: 25.sp,color: AppColor.primary),
            textAlign: TextAlign.center,

          ),
        ],
      ),
    );
  }
}

class _UserHeader extends GetView<HomeController> {
  const _UserHeader();

  @override
  Widget build(BuildContext context) {
    final size = 64.r;
    return Obx(() {
      final name = controller.user.value?.name;
      return Column(
        children: [
          controller.isUserLoading.value && controller.user.value == null
              ? ShimmerBox(width: size, height: size, borderRadius: size / 2)
              : ClipOval(
                  child: CachedImage(
                    imgUrl: controller.avatarUrl,
                    width: size,
                    height: size,
                  ),
                ),
          if (name != null && name.isNotEmpty) ...[
            8.height,
            AppText('Hi, $name', style: context.titleMedium),
          ],
        ],
      );
    });
  }
}
