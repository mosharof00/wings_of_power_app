import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../gen/assets.gen.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_radius.dart';
import '../../../global/widgets/app_input_text_form_field.dart';
import '../../../global/widgets/global_button.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColor.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(Assets.backgrounds.bgAuthSky.path, fit: BoxFit.cover),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 36.h, 24.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    Assets.logos.logoWordmark.path,
                    width: 230.w,
                    height: 120.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 48.h),
                  _LipField(
                    child: TextFormField(
                      controller: controller.username,
                      textInputAction: TextInputAction.next,
                      style: _fieldStyle(),
                      decoration: _decoration(
                        context,
                        hint: 'User Name',
                        icon: Icons.person_outline,
                      ),
                      onChanged: (_) => controller.clearError(),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  const _PasswordField(),
                  SizedBox(height: 16.h),
                  const _RememberRow(),
                  Obx(() {
                    final message = controller.error.value;
                    if (message.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.error,
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 18.h),
                  Obx(
                    () => GlobalButton(
                      text: 'Let’s Get Started',
                      isLoading: controller.submitting.value,
                      onTap: controller.submit,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const _JoinLine(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RememberRow extends GetView<LoginController> {
  const _RememberRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Obx(
          () => _RememberBox(
            checked: controller.remember.value,
            onTap: controller.toggleRemember,
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: controller.toggleRemember,
          child: Text(
            'Remember Device',
            style: GoogleFonts.nunito(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.secondary,
            ),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: controller.forgotPassword,
          child: Text(
            'Forgot Password?',
            style: GoogleFonts.nunito(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _RememberBox extends StatelessWidget {
  const _RememberBox({required this.checked, required this.onTap});

  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 18.w,
        height: 18.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(3.r),
          border: Border.all(color: AppColor.secondary, width: 1.4),
        ),
        child: checked
            ? Icon(Icons.check, size: 14.w, color: AppColor.secondary)
            : null,
      ),
    );
  }
}

class _JoinLine extends GetView<LoginController> {
  const _JoinLine();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.nunito(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColor.subtitle,
        ),
        children: [
          const TextSpan(text: 'Don’t have any account? '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: controller.openJoin,
              child: Text(
                'Join with code',
                style: GoogleFonts.nunito(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColor.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _PasswordField extends GetView<LoginController> {
  const _PasswordField();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _LipField(
        child: TextFormField(
          controller: controller.password,
          obscureText: controller.obscure.value,
          textInputAction: TextInputAction.done,
          style: _fieldStyle(),
          decoration: _decoration(
            context,
            hint: 'Password',
            icon: Icons.lock_outline,
            suffix: IconButton(
              onPressed: controller.toggleObscure,
              icon: Icon(
                controller.obscure.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColor.hintText,
                size: 20.sp,
              ),
            ),
          ),
          onChanged: (_) => controller.clearError(),
          onFieldSubmitted: (_) => controller.submit(),
        ),
      ),
    );
  }
}

class _LipField extends StatelessWidget {
  const _LipField({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.button.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.buttonLip,
            offset: Offset(0, 3.h),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

TextStyle _fieldStyle() {
  return GoogleFonts.nunito(
    fontSize: 15.sp,
    fontWeight: FontWeight.w600,
    color: AppColor.secondary,
  );
}

InputDecoration _decoration(
  BuildContext context, {
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  return buildAppInputDecoration(
    context: context,
    hintText: hint,
    prefixIcon: Icon(icon, color: AppColor.hintText, size: 20.sp),
    suffixIcon: suffix,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
  );
}
