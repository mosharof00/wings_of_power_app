import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_radius.dart';
import '../../../global/widgets/app_input_text_form_field.dart';
import '../../../global/widgets/global_button.dart';
import '../../../../gen/assets.gen.dart';
import '../controllers/account_setup_controller.dart';

class AccountSetupView extends GetView<AccountSetupController> {
  const AccountSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return switch (controller.step.value) {
        SetupStep.credentials => const _CredentialsStep(),
        SetupStep.nickname => const _NicknameStep(),
        SetupStep.realName => const _RealNameStep(),
      };
    });
  }
}

class _CredentialsStep extends GetView<AccountSetupController> {
  const _CredentialsStep();

  @override
  Widget build(BuildContext context) {
    return _SetupScaffold(
      step: '1/2',
      title: 'Set your profile first!',
      fields: [
        _LipField(
          child: TextFormField(
            controller: controller.username,
            textInputAction: TextInputAction.next,
            style: _fieldStyle(context),
            decoration: _decoration(
              context,
              hint: 'User Name',
              icon: Icons.person_outline,
            ),
          ),
        ),
        SizedBox(height: 14.h),
        _SecretField(controller: controller.password, hint: 'Password'),
        SizedBox(height: 14.h),
        _SecretField(
          controller: controller.confirmPassword,
          hint: 'Confirm Password',
        ),
      ],
      action: 'Continue',
      enabled: true,
      onAction: controller.continueCredentials,
    );
  }
}

class _NicknameStep extends GetView<AccountSetupController> {
  const _NicknameStep();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _SetupScaffold(
        step: '1/2',
        title: 'Use a nick name',
        fields: [
          _LipField(
            child: TextFormField(
              controller: controller.nickname,
              textInputAction: TextInputAction.done,
              style: _fieldStyle(context),
              decoration: _decoration(context, hint: ''),
              onChanged: controller.onNickname,
            ),
          ),
        ],
        action: 'Next',
        enabled: controller.nicknameValue.value.trim().isNotEmpty,
        onAction: controller.continueNickname,
      ),
    );
  }
}

class _RealNameStep extends GetView<AccountSetupController> {
  const _RealNameStep();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _SetupScaffold(
        step: '2/2',
        title: 'Enter your name',
        fields: [
          _LipField(
            child: TextFormField(
              controller: controller.realName,
              autofocus: true,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              style: _fieldStyle(context),
              decoration: _decoration(context, hint: ''),
              onChanged: controller.onRealName,
            ),
          ),
        ],
        action: 'Continue',
        enabled: controller.realNameValue.value.trim().isNotEmpty,
        loading: controller.submitting.value,
        onAction: controller.register,
      ),
    );
  }
}

class _SetupScaffold extends StatelessWidget {
  const _SetupScaffold({
    required this.step,
    required this.title,
    required this.fields,
    required this.action,
    required this.enabled,
    required this.onAction,
    this.loading = false,
  });

  final String step;
  final String title;
  final List<Widget> fields;
  final String action;
  final bool enabled;
  final bool loading;
  final VoidCallback onAction;

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
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      step,
                      style: GoogleFonts.nunito(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.subtitle,
                      ),
                    ),
                  ),
                  SizedBox(height: 28.h),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColor.secondary,
                    ),
                  ),
                  SizedBox(height: 22.h),
                  ...fields,
                  const Spacer(),
                  GlobalButton(
                    text: action,
                    isDisabled: !enabled,
                    isLoading: loading,
                    onTap: onAction,
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

class _SecretField extends StatefulWidget {
  const _SecretField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  State<_SecretField> createState() => _SecretFieldState();
}

class _SecretFieldState extends State<_SecretField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return _LipField(
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscure,
        style: _fieldStyle(context),
        decoration: _decoration(
          context,
          hint: widget.hint,
          icon: Icons.lock_outline,
          suffix: IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Icon(
              _obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColor.hintText,
              size: 20.sp,
            ),
          ),
        ),
      ),
    );
  }
}

TextStyle _fieldStyle(BuildContext context) {
  return GoogleFonts.nunito(
    fontSize: 15.sp,
    fontWeight: FontWeight.w600,
    color: AppColor.secondary,
  );
}

InputDecoration _decoration(
  BuildContext context, {
  required String hint,
  IconData? icon,
  Widget? suffix,
}) {
  return buildAppInputDecoration(
    context: context,
    hintText: hint.isEmpty ? null : hint,
    prefixIcon: icon == null
        ? null
        : Icon(icon, color: AppColor.hintText, size: 20.sp),
    suffixIcon: suffix,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
  );
}
