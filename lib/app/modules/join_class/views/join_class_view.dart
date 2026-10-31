import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../gen/assets.gen.dart';
import '../../../core/theme/app_color.dart';
import '../../../global/widgets/global_button.dart';
import '../controllers/join_class_controller.dart';

class JoinClassView extends GetView<JoinClassController> {
  const JoinClassView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return switch (controller.step.value) {
        JoinStep.entry => const _CodeEntry(),
        JoinStep.wrong => const _CodeMessage(
            title: 'Hmm, that code doesn’t\nlook right!',
            body: 'Talk with your teacher and try again later',
            action: 'Try Again!',
          ),
        JoinStep.expired => const _CodeMessage(
            title: 'This code isn’t working\nanymore.',
            body: 'Ask your teacher for a new code.',
            action: 'Ok, Got it!',
          ),
        JoinStep.success => const _JoinedClass(),
      };
    });
  }
}

class _CodeEntry extends GetView<JoinClassController> {
  const _CodeEntry();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _AuthSky(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 12.h),
              child: Column(
                children: [
                  Text(
                    'Enter the Class Code',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColor.secondary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Enter the class join code your teacher gave\nyou to join your class!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.subtitle,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  GestureDetector(
                    onTap: controller.focusNode.requestFocus,
                    child: Obx(() {
                      final value = controller.digits.value;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (var i = 0; i < 6; i++)
                            _DigitCircle(
                              digit: i < value.length ? value[i] : null,
                            ),
                        ],
                      );
                    }),
                  ),
                  SizedBox(
                    height: 0,
                    child: TextField(
                      controller: controller.codeController,
                      focusNode: controller.focusNode,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Colors.transparent, fontSize: 1),
                      cursorColor: Colors.transparent,
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                      ),
                      onChanged: controller.onCodeChanged,
                    ),
                  ),
                  const Spacer(),
                  Obx(
                    () => GlobalButton(
                      text: 'Join Class',
                      isDisabled: controller.digits.value.length < 6,
                      isLoading: controller.submitting.value,
                      onTap: controller.submit,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  GestureDetector(
                    onTap: controller.openLogin,
                    child: Text.rich(
                      TextSpan(
                        style: GoogleFonts.nunito(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.subtitle,
                        ),
                        children: [
                          const TextSpan(text: 'Already Joined? '),
                          TextSpan(
                            text: 'Login Here',
                            style: GoogleFonts.nunito(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColor.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DigitCircle extends StatelessWidget {
  const _DigitCircle({required this.digit});

  final String? digit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColor.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColor.buttonLip,
            offset: Offset(0, 3.h),
            blurRadius: 0,
          ),
        ],
      ),
      child: digit == null
          ? Container(
              width: 10.w,
              height: 2.h,
              color: const Color(0xFF777980),
            )
          : Text(
              digit!,
              style: GoogleFonts.nunito(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.secondary,
              ),
            ),
    );
  }
}

class _CodeMessage extends GetView<JoinClassController> {
  const _CodeMessage({
    required this.title,
    required this.body,
    required this.action,
  });

  final String title;
  final String body;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _AuthSky(),
          Align(
            alignment: Alignment.topRight,
            child: Image.asset(
              Assets.characters.heroCodeError.path,
              width: 320.w,
              fit: BoxFit.contain,
              alignment: Alignment.topRight,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
              child: Column(
                children: [
                  const Spacer(flex: 6),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColor.secondary,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.subtitle,
                    ),
                  ),
                  const Spacer(flex: 2),
                  GlobalButton(text: action, onTap: controller.backToCode),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinedClass extends GetView<JoinClassController> {
  const _JoinedClass();

  @override
  Widget build(BuildContext context) {
    final className = controller.className ?? '';
    final teacherName = controller.teacherName ?? '';
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _AuthSky(),
          const CustomPaint(painter: _SunburstPainter()),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: const BoxDecoration(
                      color: AppColor.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: AppColor.white,
                      size: 72.w,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  Text(
                    'Joined $className, $teacherName Class!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColor.secondary,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'Congratulations! You’ve successfully joined\nthe class and set your profile now',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.subtitle,
                      height: 1.35,
                    ),
                  ),
                  const Spacer(flex: 2),
                  GlobalButton(
                    text: 'Set Up your Profile',
                    onTap: controller.continueSetup,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthSky extends StatelessWidget {
  const _AuthSky();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      Assets.backgrounds.bgAuthSky.path,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}

class _SunburstPainter extends CustomPainter {
  const _SunburstPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.38);
    final paint = Paint()..color = const Color(0xFFDCC4B5);
    const rays = 16;
    final sweep = math.pi * 2 / rays;
    final radius = size.longestSide;
    for (var i = 0; i < rays; i += 2) {
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2 + i * sweep,
          sweep * 0.72,
          false,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
