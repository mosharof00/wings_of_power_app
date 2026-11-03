import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

import '../controllers/profile_controller.dart';

class ChangePasswordView extends GetView<ProfileController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Stack(
        children: [
          // Sky background banner
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Assets.backgrounds.bgHomeSky.image(
              fit: BoxFit.fill,
              height: 140.h,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),

                    // Header bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: const BoxDecoration(
                              color: AppColor.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        Text(
                          'Change Password',
                          style: GoogleFonts.nunito(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColor.secondary,
                          ),
                        ),
                        SizedBox(width: 44.w),
                      ],
                    ),

                    SizedBox(height: 28.h),

                    // Error banner if any
                    Obx(() {
                      final error = controller.passwordError.value;
                      if (error.isEmpty) return const SizedBox.shrink();

                      return Container(
                        margin: EdgeInsets.only(bottom: 18.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE8E8),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFF8B4B4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColor.error,
                              size: 20,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                error,
                                style: GoogleFonts.nunito(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Field 1: Current Password
                    _buildPasswordField(
                      label: 'Current Password',
                      controller: controller.currentPasswordController,
                      obscureRx: controller.obscureCurrent,
                      hintText: 'Enter current password',
                    ),

                    SizedBox(height: 18.h),

                    // Field 2: New Password
                    _buildPasswordField(
                      label: 'New Password',
                      controller: controller.newPasswordController,
                      obscureRx: controller.obscureNew,
                      hintText: 'Enter new password',
                    ),

                    SizedBox(height: 18.h),

                    // Field 3: Confirm Password
                    _buildPasswordField(
                      label: 'Confirm Password',
                      controller: controller.confirmPasswordController,
                      obscureRx: controller.obscureConfirm,
                      hintText: 'Confirm new password',
                    ),

                    SizedBox(height: 36.h),

                    // Update Password Button
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: controller.isChangingPassword.value
                              ? null
                              : controller.submitChangePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            disabledBackgroundColor: AppColor.primaryDisable,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                          ),
                          child: controller.isChangingPassword.value
                              ? SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  'Update Password',
                                  style: GoogleFonts.nunito(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required RxBool obscureRx,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColor.secondary,
          ),
        ),
        SizedBox(height: 6.h),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE8E9EC)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    obscureText: obscureRx.value,
                    style: GoogleFonts.nunito(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColor.secondary,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hintText,
                      hintStyle: GoogleFonts.nunito(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.hintText,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: obscureRx.toggle,
                  icon: Icon(
                    obscureRx.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColor.subtitle,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

