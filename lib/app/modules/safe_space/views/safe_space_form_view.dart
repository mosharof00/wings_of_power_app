import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/safe_space_models.dart';
import 'package:wings_of_power_app/app/global/widgets/global_button.dart';
import '../controllers/safe_space_controller.dart';
import '../widgets/safe_space_category_card.dart';
import '../widgets/safe_space_step_indicator.dart';

class SafeSpaceFormView extends GetView<SafeSpaceController> {
  const SafeSpaceFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC3EAFF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top Bar with Step Indicator ──────────────────────────
            Obx(
              () => SafeSpaceStepIndicator(
                currentStep: controller.currentStep.value,
                totalSteps: 3,
                onBack: controller.previousStep,
              ),
            ),
            SizedBox(height: 12.h),

            // ── White Card Container ─────────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32.r),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                    child: Obx(() {
                      switch (controller.currentStep.value) {
                        case 1:
                          return _buildStep1(context);
                        case 2:
                          return _buildStep2(context);
                        case 3:
                        default:
                          return _buildStep3(context);
                      }
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Category Selection ───────────────────────────────────────────
  Widget _buildStep1(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeaderBanner('What is it about?'),
        SizedBox(height: 28.h),
        Row(
          children: [
            Expanded(
              child: SafeSpaceCategoryCard(
                title: SafeSpaceCategory.hurtfulWords,
                isSelected: controller.selectedCategory.value ==
                    SafeSpaceCategory.hurtfulWords,
                onTap: () =>
                    controller.selectCategory(SafeSpaceCategory.hurtfulWords),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: SafeSpaceCategoryCard(
                title: SafeSpaceCategory.cyberbullying,
                isSelected: controller.selectedCategory.value ==
                    SafeSpaceCategory.cyberbullying,
                onTap: () =>
                    controller.selectCategory(SafeSpaceCategory.cyberbullying),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            Expanded(
              child: SafeSpaceCategoryCard(
                title: SafeSpaceCategory.physicalPush,
                isSelected: controller.selectedCategory.value ==
                    SafeSpaceCategory.physicalPush,
                onTap: () =>
                    controller.selectCategory(SafeSpaceCategory.physicalPush),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: SafeSpaceCategoryCard(
                title: SafeSpaceCategory.somethingElse,
                isSelected: controller.selectedCategory.value ==
                    SafeSpaceCategory.somethingElse,
                onTap: () =>
                    controller.selectCategory(SafeSpaceCategory.somethingElse),
              ),
            ),
          ],
        ),
        const Spacer(),
        GlobalButton(
          onTap: controller.nextStep,
          text: 'Next',
          isDisabled: !controller.canProceedStep1,
          height: 52.h,
          borderRadius: BorderRadius.circular(26.r),
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }

  // ── Step 2: Description Text Area ────────────────────────────────────────
  Widget _buildStep2(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeaderBanner('Share when & what\nhappened in your own words'),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9F2),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFFF7CEB6),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              TextField(
                controller: controller.bodyTextController,
                maxLength: SafeSpaceController.maxBodyLength,
                maxLines: 7,
                buildCounter: (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) =>
                    null,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColor.secondary,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tell us what happened...',
                  hintStyle: TextStyle(
                    fontSize: 14.5.sp,
                    color: AppColor.hintText,
                  ),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '${controller.characterCount.value}/${SafeSpaceController.maxBodyLength}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColor.hintText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        GlobalButton(
          onTap: controller.nextStep,
          text: 'Next',
          height: 52.h,
          borderRadius: BorderRadius.circular(26.r),
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }

  // ── Step 3: Feel Safe Yes/No ──────────────────────────────────────────────
  Widget _buildStep3(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeaderBanner('Do you feel safe right now?'),
        SizedBox(height: 28.h),
        _buildYesNoOption(
          label: 'Yes',
          isSelected: controller.feelSafe.value == true,
          onTap: () => controller.selectFeelSafe(true),
        ),
        SizedBox(height: 14.h),
        _buildYesNoOption(
          label: 'No',
          isSelected: controller.feelSafe.value == false,
          onTap: () => controller.selectFeelSafe(false),
        ),
        const Spacer(),
        GlobalButton(
          onTap: controller.submitReport,
          text: 'Submit Report',
          isLoading: controller.isSubmitting.value,
          isDisabled: !controller.canSubmit,
          height: 52.h,
          borderRadius: BorderRadius.circular(26.r),
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
        SizedBox(height: 12.h),
        InkWell(
          onTap: controller.cancelForm,
          borderRadius: BorderRadius.circular(26.r),
          child: Container(
            height: 52.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26.r),
              border: Border.all(
                color: AppColor.primary,
                width: 1.5,
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Header Banner Card ───────────────────────────────────────────────────
  Widget _buildHeaderBanner(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFE68235),
          width: 1.5,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w800,
          color: AppColor.secondary,
          height: 1.25,
        ),
      ),
    );
  }

  // ── Yes/No Option Card ───────────────────────────────────────────────────
  Widget _buildYesNoOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF6ED) : const Color(0xFFFFF9F5),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColor.primary : const Color(0xFFF7CEB6),
            width: isSelected ? 2.0 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.secondary,
              ),
            ),
            const Spacer(),
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColor.primary : const Color(0xFFF7CEB6),
                  width: 2.0,
                ),
                color: isSelected ? AppColor.primary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.circle,
                      size: 10.sp,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
