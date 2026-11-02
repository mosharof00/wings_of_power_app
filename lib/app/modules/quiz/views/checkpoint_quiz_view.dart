import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/quiz_models.dart';
import 'package:wings_of_power_app/app/global/widgets/error_block.dart';
import '../controllers/quiz_controller.dart';

class CheckpointQuizView extends GetView<QuizController> {
  const CheckpointQuizView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.checkpointQuiz.value == null) {
        controller.loadCheckpointQuiz();
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Blurred background over reader page
          Positioned.fill(
            child: GestureDetector(
              onTap: () {}, // Do not dismiss on outside tap to preserve gate
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/book_covers/page_sample_1.png',
                    fit: BoxFit.cover,
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Bottom Sheet Content
          Align(
            alignment: Alignment.bottomCenter,
            child: Obx(() {
              if (controller.isLoading.value) {
                return Container(
                  height: 380.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28.r),
                      topRight: Radius.circular(28.r),
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE06D28),
                    ),
                  ),
                );
              }

              if (controller.isError.value) {
                return Container(
                  height: 380.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28.r),
                      topRight: Radius.circular(28.r),
                    ),
                  ),
                  child: ErrorBlock(
                    message: controller.errorMessage.value,
                    onRetry: controller.loadCheckpointQuiz,
                  ),
                );
              }

              final question = controller.currentCheckpointQuestion;
              if (question == null) {
                return Container(
                  height: 380.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28.r),
                      topRight: Radius.circular(28.r),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'No checkpoint question',
                      style: GoogleFonts.nunito(
                        fontSize: 16.sp,
                        color: AppColor.secondary,
                      ),
                    ),
                  ),
                );
              }

              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28.r),
                    topRight: Radius.circular(28.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top Header: "Quick Check!" + Speaker Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Quick Check!',
                              style: GoogleFonts.nunito(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E1B4B),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: controller.toggleSpeaker,
                              child: Container(
                                width: 36.w,
                                height: 36.w,
                                decoration: BoxDecoration(
                                  color: controller.isTtsSpeaking.value
                                      ? const Color(0xFFFDBA74)
                                      : const Color(0xFFFFEDD5),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/ic_speaker.svg',
                                    width: 18.w,
                                    height: 18.w,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Host Question Box
                        _buildHostQuestionCard(question),

                        SizedBox(height: 18.h),

                        // Options
                        _buildOptions(question),

                        SizedBox(height: 20.h),

                        // Submit Answer button
                        _buildSubmitButton(context),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHostQuestionCard(QuizQuestionModel question) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Question Box
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 48.h),
          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 20.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8EE),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: const Color(0xFFE06D28),
              width: 2.w,
            ),
          ),
          child: Text(
            question.prompt,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E1B4B),
              height: 1.35,
            ),
          ),
        ),

        // Orange Gabriel Tag
        Positioned(
          top: 32.h,
          left: 78.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE06D28),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.r),
                topRight: Radius.circular(10.r),
              ),
            ),
            child: Text(
              'Gabriel',
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Gabriel image
        Positioned(
          top: -16.h,
          left: 4.w,
          child: Image.asset(
            'assets/characters/gabriel_host.png',
            height: 104.h,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(QuizQuestionModel question) {
    final isTrueFalse =
        question.type == 'TRUE_FALSE' || question.options.length == 2;
    final letters = ['A', 'B', 'C', 'D'];
    final options = question.options;

    if (isTrueFalse) {
      return Row(
        children: [
          Expanded(
            child: options.isNotEmpty
                ? _buildOptionItem(options[0], letters[0])
                : const SizedBox.shrink(),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: options.length > 1
                ? _buildOptionItem(options[1], letters[1])
                : const SizedBox.shrink(),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: options.isNotEmpty
                  ? _buildOptionItem(options[0], letters[0])
                  : const SizedBox.shrink(),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: options.length > 1
                  ? _buildOptionItem(options[1], letters[1])
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: options.length > 2
                  ? _buildOptionItem(options[2], letters[2])
                  : const SizedBox.shrink(),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: options.length > 3
                  ? _buildOptionItem(options[3], letters[3])
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionItem(QuizOptionModel option, String letter) {
    final isSelected =
        controller.selectedCheckpointOptionId.value == option.id;

    return GestureDetector(
      onTap: () => controller.selectCheckpointOption(option.id),
      child: Container(
        height: 78.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE06D28)
                : const Color(0xFFFED7AA),
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE06D28)
                    : const Color(0xFFFFEDD5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: GoogleFonts.nunito(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : const Color(0xFF7C2D12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              option.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E1B4B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final hasSelection =
        controller.selectedCheckpointOptionId.value != null;

    return GestureDetector(
      onTap: hasSelection
          ? () async {
              final res = await controller.submitCheckpointAnswer();
              if (res == null) return;

              if (res.isCorrect) {
                // Show Success Modal
                if (!context.mounted) return;
                _showSuccessModal(context);
              } else {
                if (controller.checkpointAttemptCount.value == 1) {
                  // Show 1st wrong attempt hint modal
                  if (!context.mounted) return;
                  _showFirstWrongModal(
                    context,
                    res.hint ??
                        'Remember when Faith saw Mia sitting alone? Faith smiled and spoke kindly.',
                  );
                } else {
                  // Show 2nd wrong attempt reveal modal
                  if (!context.mounted) return;
                  _showSecondWrongModal(
                    context,
                    res.explanation ??
                        'The answer is:\n“Want to sit with us?” Faith was\nbeing kind.',
                  );
                }
              }
            }
          : null,
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          color: hasSelection
              ? const Color(0xFFE06D28)
              : const Color(0xFFFED7AA),
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: hasSelection
              ? [
                  BoxShadow(
                    color: const Color(0xFFE06D28).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            'Submit Answer',
            style: GoogleFonts.nunito(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessModal(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8EE),
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gabriel celebrating illustration
              Image.asset(
                'assets/characters/gabriel_host.png',
                height: 140.h,
                fit: BoxFit.contain,
              ),

              SizedBox(height: 16.h),

              // Title
              Text(
                'Yes! That’s right! You’re a great reader!',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1B4B),
                  height: 1.3,
                ),
              ),

              SizedBox(height: 24.h),

              // Keep Reading button
              GestureDetector(
                onTap: () {
                  Get.back(); // close dialog
                  Get.back(result: true); // close checkpoint and pass back to reader
                },
                child: Container(
                  width: double.infinity,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE06D28),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE06D28).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Keep Reading',
                      style: GoogleFonts.nunito(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showFirstWrongModal(BuildContext context, String hint) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8EE),
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gabriel illustration
              Image.asset(
                'assets/characters/gabriel_host.png',
                height: 130.h,
                fit: BoxFit.contain,
              ),

              SizedBox(height: 14.h),

              // Title
              Text(
                '“Hmm, not right. Let’s look back together!”',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1B4B),
                  height: 1.3,
                ),
              ),

              SizedBox(height: 14.h),

              // Hint Box
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Hint: $hint',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4B5563),
                    height: 1.35,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Try Again! button
              GestureDetector(
                onTap: () {
                  Get.back(); // close dialog, allow 2nd attempt
                },
                child: Container(
                  width: double.infinity,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE06D28),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE06D28).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Try Again!',
                      style: GoogleFonts.nunito(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showSecondWrongModal(BuildContext context, String explanation) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8EE),
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gabriel illustration
              Image.asset(
                'assets/characters/gabriel_host.png',
                height: 130.h,
                fit: BoxFit.contain,
              ),

              SizedBox(height: 14.h),

              // Title
              Text(
                'Good try!',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1B4B),
                ),
              ),

              SizedBox(height: 14.h),

              // Answer Reveal Box
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  explanation,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4B5563),
                    height: 1.35,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Keep Reading button
              GestureDetector(
                onTap: () {
                  Get.back(); // close dialog
                  Get.back(result: true); // return true to reader to continue
                },
                child: Container(
                  width: double.infinity,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE06D28),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE06D28).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Keep Reading',
                      style: GoogleFonts.nunito(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
