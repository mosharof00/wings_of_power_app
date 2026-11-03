import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/mocks/profile.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

import '../controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

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

                    // Header: Back button + "Edit Profile" + spacer
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
                          'Edit Profile',
                          style: GoogleFonts.nunito(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColor.secondary,
                          ),
                        ),
                        SizedBox(width: 44.w),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Top Avatar Preview
                    Center(
                      child: Obx(() {
                        final avatar = controller.selectedAvatar.value;
                        return Container(
                          width: 104.w,
                          height: 104.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.white,
                              width: 3.5.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: avatar.startsWith('assets/')
                                ? Image.asset(
                                    avatar,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    avatar,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Image.asset(
                                      'assets/images/avatar_01.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: 24.h),

                    // "Select an Avatar" section
                    Text(
                      'Select an Avatar',
                      style: GoogleFonts.nunito(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColor.secondary,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Preset Avatars 2x4 Grid
                    Obx(() {
                      final selected = controller.selectedAvatar.value;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ProfileMock.presetAvatars.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          final path = ProfileMock.presetAvatars[index];
                          final isCurrent = selected == path;

                          return GestureDetector(
                            onTap: () => controller.selectAvatar(path),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: isCurrent
                                          ? AppColor.primary
                                          : Colors.white,
                                      width: isCurrent ? 3.w : 1.5.w,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.06),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      path,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                if (isCurrent)
                                  Positioned(
                                    right: 2.w,
                                    top: 2.h,
                                    child: Container(
                                      width: 20.w,
                                      height: 20.w,
                                      decoration: BoxDecoration(
                                        color: AppColor.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.w,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.check_rounded,
                                        size: 12.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    }),

                    SizedBox(height: 24.h),

                    // "Personal Details" section
                    Text(
                      'Personal Details',
                      style: GoogleFonts.nunito(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColor.secondary,
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Your Name Field
                    Text(
                      'Your Name',
                      style: GoogleFonts.nunito(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.secondary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: const Color(0xFFE8E9EC)),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 2.h,
                      ),
                      child: TextFormField(
                        controller: controller.nameController,
                        style: GoogleFonts.nunito(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.secondary,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your name',
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Your Class Field (Read-only)
                    Text(
                      'Your Class',
                      style: GoogleFonts.nunito(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.secondary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: const Color(0xFFE8E9EC)),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      child: Obx(() {
                        final className =
                            controller.profile.value?.displayClassName ??
                                'Grade 4, Ms. Smith';
                        return Text(
                          className,
                          style: GoogleFonts.nunito(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColor.subtitle,
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: 36.h),

                    // Save Changes Button
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: controller.isSaving.value
                              ? null
                              : controller.saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            disabledBackgroundColor: AppColor.primaryDisable,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                          ),
                          child: controller.isSaving.value
                              ? SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  'Save Changes',
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
}
