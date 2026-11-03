import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

import '../controllers/profile_controller.dart';

class SettingsView extends GetView<ProfileController> {
  const SettingsView({super.key});

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),

                  // Header bar: [Back Button] ... "Settings" ... [Spacer]
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
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
                          'Settings',
                          style: GoogleFonts.nunito(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColor.secondary,
                          ),
                        ),
                        SizedBox(width: 44.w),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h),

                  // Content Container (Cream sheet background)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.cream,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Reading
                        _buildSectionHeader('Reading'),
                        SizedBox(height: 8.h),
                        _buildCardContainer(
                          children: [
                            Obx(
                              () => _buildToggleRow(
                                title: 'Read to Me',
                                subtitle: 'Gabirel reads the story aloud',
                                value: controller.settings.value.readToMe,
                                onChanged: controller.toggleReadToMe,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 18.h),

                        // 2. Sound
                        _buildSectionHeader('Sound'),
                        SizedBox(height: 8.h),
                        _buildCardContainer(
                          children: [
                            Obx(
                              () => _buildToggleRow(
                                title: 'Sound Effect',
                                subtitle: 'Change the sound effects',
                                value: controller.settings.value.soundEffect,
                                onChanged: controller.toggleSound,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 18.h),

                        // 3. Notifications
                        _buildSectionHeader('Notifications'),
                        SizedBox(height: 8.h),
                        _buildCardContainer(
                          children: [
                            Obx(
                              () => _buildToggleRow(
                                title: 'Stories',
                                value: controller.settings.value.notifyStories,
                                onChanged: controller.toggleStories,
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFF1F2F2)),
                            Obx(
                              () => _buildToggleRow(
                                title: 'Badges & Achievements',
                                value: controller.settings.value.notifyBadges,
                                onChanged: controller.toggleBadges,
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFF1F2F2)),
                            Obx(
                              () => _buildToggleRow(
                                title: 'Game Show',
                                value: controller.settings.value.notifyGameShow,
                                onChanged: controller.toggleGameShow,
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFF1F2F2)),
                            Obx(
                              () => _buildToggleRow(
                                title: 'Safe Space Activity',
                                value: controller.settings.value.notifySafeSpace,
                                onChanged: controller.toggleSafeSpace,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 18.h),

                        // 4. My Account
                        _buildSectionHeader('My Account'),
                        SizedBox(height: 8.h),
                        _buildCardContainer(
                          children: [
                            _buildNavigationRow(
                              title: 'Change Password',
                              subtitle: 'Update your password',
                              onTap: controller.openChangePassword,
                            ),
                            const Divider(height: 1, color: Color(0xFFF1F2F2)),
                            _buildNavigationRow(
                              title: 'Log Out',
                              subtitle: 'You can log out anytime from here',
                              onTap: controller.openLogoutSheet,
                            ),
                          ],
                        ),

                        SizedBox(height: 18.h),

                        // 5. Help
                        _buildSectionHeader('Help'),
                        SizedBox(height: 8.h),
                        _buildCardContainer(
                          children: [
                            _buildNavigationRow(
                              title: 'I Need Help',
                              onTap: controller.openSafeSpaceIntro,
                            ),
                            const Divider(height: 1, color: Color(0xFFF1F2F2)),
                            _buildNavigationRow(
                              title: 'How the App Work',
                              onTap: controller.openHowAppWorksSheet,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.nunito(
        fontSize: 14.sp,
        fontWeight: FontWeight.w800,
        color: AppColor.secondary,
      ),
    );
  }

  Widget _buildCardContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.secondary,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.subtitle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColor.primary,
            activeTrackColor: AppColor.primary.withValues(alpha: 0.5),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRow({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.secondary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: GoogleFonts.nunito(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.subtitle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColor.secondary,
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
