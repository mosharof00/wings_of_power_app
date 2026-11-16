import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_radius.dart';
import '../../../global/widgets/app_input_text_form_field.dart';
import '../../../global/widgets/app_scaffold.dart';
import '../../../global/widgets/global_button.dart';
import '../controllers/account_setup_controller.dart';

class AccountSetupView extends GetView<AccountSetupController> {
  const AccountSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return switch (controller.step.value) {
        SetupStep.form => const _FormStep(),
        SetupStep.avatar => const _AvatarStep(),
      };
    });
  }
}

class _FormStep extends GetView<AccountSetupController> {
  const _FormStep();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '1/2',
                  style: GoogleFonts.nunito(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.subtitle,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Set your profile first!',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColor.secondary,
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LipField(
                        child: TextFormField(
                          controller: controller.username,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          style: _fieldStyle(),
                          decoration: _decoration(
                            context,
                            hint: 'User Name',
                            icon: Icons.person_outline,
                            suffix: Obx(() {
                              final status = controller.usernameStatus.value;
                              if (status == UsernameCheckStatus.checking) {
                                return Padding(
                                  padding: EdgeInsets.all(12.w),
                                  child: SizedBox(
                                    width: 16.w,
                                    height: 16.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColor.primary,
                                    ),
                                  ),
                                );
                              }
                              if (status == UsernameCheckStatus.available) {
                                return Icon(
                                  Icons.check_circle_outline,
                                  color: AppColor.success,
                                  size: 20.sp,
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                          ),
                          onChanged: controller.onUsernameEdited,
                        ),
                      ),
                      const _UsernameFeedback(),
                      SizedBox(height: 12.h),
                      _SecretField(
                        controller: controller.password,
                        hint: 'Password',
                        onChanged: (_) => controller.onFieldEdited(),
                      ),
                      _FieldError(controller.passwordError),
                      SizedBox(height: 12.h),
                      _SecretField(
                        controller: controller.confirmPassword,
                        hint: 'Confirm Password',
                        onChanged: (_) => controller.onFieldEdited(),
                      ),
                      _FieldError(controller.confirmError),
                      SizedBox(height: 12.h),
                      _LipField(
                        child: TextFormField(
                          controller: controller.nickname,
                          textInputAction: TextInputAction.next,
                          style: _fieldStyle(),
                          decoration: _decoration(
                            context,
                            hint: 'Nick Name',
                            icon: Icons.badge_outlined,
                          ),
                          onChanged: (_) => controller.onFieldEdited(),
                        ),
                      ),
                      _FieldError(controller.nicknameError),
                      SizedBox(height: 12.h),
                      _LipField(
                        child: TextFormField(
                          controller: controller.realName,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          style: _fieldStyle(),
                          decoration: _decoration(
                            context,
                            hint: 'Real Name',
                            icon: Icons.edit_outlined,
                          ),
                          onChanged: (_) => controller.onFieldEdited(),
                        ),
                      ),
                      _FieldError(controller.realNameError),
                      SizedBox(height: 12.h),
                      _LipField(
                        child: TextFormField(
                          controller: controller.age,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          style: _fieldStyle(),
                          decoration: _decoration(
                            context,
                            hint: 'Age',
                            icon: Icons.cake_outlined,
                          ),
                          onChanged: (_) => controller.onFieldEdited(),
                          onFieldSubmitted: (_) =>
                              controller.continueFromForm(),
                        ),
                      ),
                      _FieldError(controller.ageError),
                      Obx(() {
                        final message = controller.formError.value;
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
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
              Obx(
                () => GlobalButton(
                  text: 'Continue',
                  isDisabled: !controller.formValid.value,
                  onTap: controller.continueFromForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarStep extends GetView<AccountSetupController> {
  const _AvatarStep();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: controller.backToForm,
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18.sp,
                      color: AppColor.secondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '2/2',
                    style: GoogleFonts.nunito(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.subtitle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'Select an Avatar',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColor.secondary,
                ),
              ),
              SizedBox(height: 28.h),
              Expanded(
                child: Obx(() {
                  final selected = controller.selectedAvatar.value;
                  return GridView.builder(
                    itemCount: AccountSetupController.avatars.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 14.w,
                      mainAxisSpacing: 14.h,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final path = AccountSetupController.avatars[index];
                      final isSelected = selected == path;
                      return GestureDetector(
                        onTap: () => controller.selectAvatar(path),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.white,
                            border: Border.all(
                              color: isSelected
                                  ? AppColor.primary
                                  : AppColor.white,
                              width: isSelected ? 3.w : 1.5.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(path, fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              Obx(
                () => GlobalButton(
                  text: 'Continue',
                  isDisabled: controller.selectedAvatar.value == null,
                  isLoading: controller.submitting.value,
                  onTap: controller.submitRegistration,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsernameFeedback extends GetView<AccountSetupController> {
  const _UsernameFeedback();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final success = controller.usernameSuccess.value;
      final error = controller.usernameError.value;
      if (success.isNotEmpty) {
        return Padding(
          padding: EdgeInsets.only(top: 6.h, left: 4.w),
          child: Text(
            success,
            style: GoogleFonts.nunito(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.success,
            ),
          ),
        );
      }
      if (error.isEmpty) return SizedBox(height: 2.h);
      return Padding(
        padding: EdgeInsets.only(top: 6.h, left: 4.w),
        child: Text(
          error,
          style: GoogleFonts.nunito(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.error,
          ),
        ),
      );
    });
  }
}

class _FieldError extends StatelessWidget {
  const _FieldError(this.error);

  final RxString error;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final message = error.value;
      if (message.isEmpty) return SizedBox(height: 2.h);
      return Padding(
        padding: EdgeInsets.only(top: 6.h, left: 4.w),
        child: Text(
          message,
          style: GoogleFonts.nunito(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.error,
          ),
        ),
      );
    });
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
  const _SecretField({
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

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
        textInputAction: TextInputAction.next,
        style: _fieldStyle(),
        onChanged: widget.onChanged,
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
