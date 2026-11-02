import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/global_loading.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

class ReaderLoadingView extends StatelessWidget {
  const ReaderLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            Assets.backgrounds.bgAuthSky.path,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                Image.asset(
                  Assets.characters.heroApproval.path,
                  height: 300.h,
                  fit: BoxFit.contain,
                ),
                Transform.translate(
                  offset: Offset(0, -16.h),
                  child: const LoadingCard(
                    title: 'Loading',
                    message: 'Please wait while I fetch the story for you!',
                  ),
                ),
                const Spacer(flex: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
