import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../gen/assets.gen.dart';
import '../../../core/theme/app_color.dart';
import '../../../global/widgets/global_button.dart';
import '../controllers/welcome_controller.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              Assets.backgrounds.bgAuthSky.path,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            bottom: 248.h,
            child: Image.asset(
              Assets.characters.welcomeHeroes.path,
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: _WelcomeCard(),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends GetView<WelcomeController> {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 8.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE4E4E8),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'Ready to Shine?',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColor.secondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Let’s get started by entering\nthe app',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColor.subtitle,
                height: 1.35,
              ),
            ),
            SizedBox(height: 22.h),
            Obx(() {
              final joinFilled =
                  controller.emphasis.value == WelcomeEmphasis.join;
              return Column(
                children: [
                  _ActionButton(
                    text: 'Log In',
                    filled: !joinFilled,
                    onTap: controller.openLogin,
                  ),
                  SizedBox(height: 12.h),
                  _ActionButton(
                    text: 'Join with Class Code',
                    filled: joinFilled,
                    onTap: controller.openJoin,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.text,
    required this.filled,
    required this.onTap,
  });

  final String text;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return GlobalButton(text: text, onTap: onTap);
    }
    return GlobalButton(
      text: text,
      onTap: onTap,
      variant: GlobalButtonVariant.secondary,
      borderColor: AppColor.primary,
    );
  }
}
