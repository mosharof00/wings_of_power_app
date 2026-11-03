import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

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
                children: [
                  SizedBox(height: 8.h),

                  // Header bar: [Back Button?] ... "Profile" ... [Settings Gear]
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (canPop)
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
                          )
                        else
                          SizedBox(width: 44.w),

                        Text(
                          'Profile',
                          style: GoogleFonts.nunito(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColor.secondary,
                          ),
                        ),

                        // Settings gear button
                        GestureDetector(
                          onTap: controller.openSettings,
                          child: Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: const BoxDecoration(
                              color: AppColor.primary,
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(11.w),
                            child: SvgPicture.asset(
                              'assets/icons/ic_settings.svg',
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h),

                  // Avatar with pencil edit badge
                  Obx(() {
                    final avatarPath = controller.profile.value?.avatarUrl ??
                        'assets/images/avatar_01.png';
                    final name = controller.profile.value?.nickname ?? 'Sarah';
                    final age = controller.profile.value?.ageText ?? '4 years old';
                    final className =
                        controller.profile.value?.displayClassName ??
                            'Grade A, Ms. Smith Class';

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: controller.openEditProfile,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 96.w,
                                height: 96.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3.w,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: avatarPath.startsWith('assets/')
                                      ? Image.asset(
                                          avatarPath,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          avatarPath,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              Image.asset(
                                            'assets/images/avatar_01.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                              ),

                              // Pencil edit badge
                              Positioned(
                                right: -2.w,
                                bottom: 2.h,
                                child: Container(
                                  width: 32.w,
                                  height: 32.w,
                                  decoration: BoxDecoration(
                                    color: AppColor.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.5.w,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.edit_rounded,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // Student Name
                        Text(
                          name,
                          style: GoogleFonts.nunito(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColor.secondary,
                          ),
                        ),
                        SizedBox(height: 4.h),

                        // Age
                        Text(
                          age,
                          style: GoogleFonts.nunito(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.subtitle,
                          ),
                        ),
                        SizedBox(height: 4.h),

                        // Class Name
                        Text(
                          className,
                          style: GoogleFonts.nunito(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondary,
                          ),
                        ),
                      ],
                    );
                  }),

                  SizedBox(height: 18.h),

                  // Three stat cards in cream container
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.cream,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Obx(() {
                        final points = controller.profile.value?.points ?? 245;
                        final badges = controller.profile.value?.badges ?? 3;
                        final progress =
                            controller.profile.value?.progressPercent ?? 30;

                        return Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                iconPath: 'assets/icons/ic_profile_points.svg',
                                value: '$points',
                                label: 'Points',
                                onTap: controller.openPositivePoints,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: _buildStatCard(
                                iconPath: 'assets/icons/ic_profile_badges.svg',
                                value: '$badges',
                                label: 'Badges',
                                onTap: controller.openBadges,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: _buildStatCard(
                                iconPath: 'assets/icons/ic_profile_progress.svg',
                                value: '$progress%',
                                label: 'Progress',
                                onTap: controller.openReadingProgress,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Menu rows (7 items)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        _buildMenuRow(
                          iconPath: 'assets/icons/ic_profile_hero.svg',
                          title: 'My Power Hero',
                          subtitle: 'View and change your character',
                          onTap: controller.openHeroes,
                        ),
                        _buildMenuRow(
                          iconPath: 'assets/icons/ic_profile_progress.svg',
                          title: 'My Reading Progress',
                          subtitle: 'Stories and chapter progress',
                          onTap: controller.openReadingProgress,
                        ),
                        _buildMenuRow(
                          iconPath: 'assets/icons/ic_profile_badges.svg',
                          title: 'Badges & Achievements',
                          subtitle: 'Your earned badges',
                          onTap: controller.openBadges,
                        ),
                        _buildMenuRow(
                          iconPath: 'assets/icons/ic_profile_points.svg',
                          title: 'Positive Points',
                          subtitle: 'View your earned points',
                          onTap: controller.openPositivePoints,
                        ),
                        _buildMenuRow(
                          iconPath: 'assets/icons/ic_profile_leaderboard.svg',
                          title: 'Leaderboard',
                          subtitle: 'See your leaderboard position',
                          onTap: controller.openLeaderboard,
                        ),
                        _buildMenuRow(
                          iconPath: 'assets/icons/ic_profile_reports.svg',
                          title: 'My Reports',
                          subtitle: 'Check your safe space report status',
                          onTap: controller.openSafeSpaceReports,
                        ),
                        _buildMenuRow(
                          iconPath: 'assets/icons/ic_profile_notifications.svg',
                          title: 'Notifications',
                          subtitle: 'Important Updates',
                          onTap: controller.onNotificationTap,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String iconPath,
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
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
          children: [
            SvgPicture.asset(
              iconPath,
              width: 26.w,
              height: 26.w,
            ),
            SizedBox(height: 6.h),
            Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColor.secondary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.subtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuRow({
    required String iconPath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDEEE5),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(9.w),
                  child: SvgPicture.asset(
                    iconPath,
                    width: 22.w,
                    height: 22.w,
                  ),
                ),
                SizedBox(width: 14.w),
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
      ),
    );
  }
}
