import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/quiz_models.dart';
import 'package:wings_of_power_app/app/global/widgets/error_block.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';
import '../controllers/quiz_controller.dart';
import 'widgets/quiz_leave_dialog.dart';

class ChapterQuizView extends GetView<QuizController> {
  const ChapterQuizView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure quiz is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.quiz.value == null && !controller.isLoading.value) {
        controller.loadChapterQuiz();
      } else if (controller.quiz.value == null) {
        controller.loadChapterQuiz();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFCBEBFE),
      body: Stack(
        children: [
          // Background sky & clouds
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260.h,
            child: Image.asset(
              Assets.backgrounds.bgHomeSky.path,
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFE06D28),
                  ),
                );
              }

              if (controller.isError.value) {
                return ErrorBlock(
                  message: controller.errorMessage.value,
                  onRetry: controller.loadChapterQuiz,
                );
              }

              final currentQ = controller.currentQuestion;
              if (currentQ == null) {
                return Center(
                  child: Text(
                    'No questions available',
                    style: GoogleFonts.nunito(
                      fontSize: 16.sp,
                      color: AppColor.secondary,
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  // 1. Top Bar: Close button, Star Progress Bar, Counter
                  _buildTopBar(context),

                  SizedBox(height: 12.h),

                  // 2. Main Sheet: Question card, MCQ Grid, Message, Action Button
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32.r),
                          topRight: Radius.circular(32.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                        child: Column(
                          children: [
                            // Speaker icon (Top Right)
                            Align(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: controller.toggleSpeaker,
                                child: Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    color: controller.isTtsSpeaking.value
                                        ? const Color(0xFFFDBA74)
                                        : const Color(0xFFFFEDD5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/icons/ic_speaker.svg',
                                      width: 20.w,
                                      height: 20.w,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Host card with Gabriel & Question box
                            _buildHostQuestionCard(currentQ),

                            SizedBox(height: 20.h),

                            // 2x2 MCQ Grid
                            _buildOptionsGrid(currentQ),

                            SizedBox(height: 18.h),

                            // Feedback message (if checked)
                            if (controller.isAnswerChecked.value)
                              _buildFeedbackMessage(),

                            SizedBox(height: 14.h),

                            // Bottom Button (Check Answer / Next Question / See Result)
                            _buildActionButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          // Close button with X
          GestureDetector(
            onTap: () {
              Get.dialog(
                QuizLeaveDialog(
                  onKeepGoing: () => Get.back(),
                  onLeave: () {
                    Get.back();
                    controller.leaveQuiz();
                  },
                ),
              );
            },
            child: Container(
              width: 42.w,
              height: 42.w,
              decoration: const BoxDecoration(
                color: Color(0xFFE06D28),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          SizedBox(width: 14.w),

          // Star progress bar
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = constraints.maxWidth;
                final total = controller.totalQuestions;
                final current = controller.currentQuestionNumber;
                final progressFraction = (current / total).clamp(0.0, 1.0);

                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Background track
                    Container(
                      height: 12.h,
                      width: barWidth,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),

                    // Active green bar
                    Container(
                      height: 12.h,
                      width: barWidth * progressFraction,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),

                    // Stars evenly distributed
                    SizedBox(
                      height: 24.h,
                      width: barWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(total, (index) {
                          final isEarned = index < current;
                          return isEarned
                              ? SvgPicture.asset(
                                  'assets/icons/ic_quiz_star.svg',
                                  width: 24.w,
                                  height: 24.w,
                                )
                              : SvgPicture.asset(
                                  'assets/icons/ic_quiz_star.svg',
                                  width: 24.w,
                                  height: 24.w,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFFE0E7FF),
                                    BlendMode.srcIn,
                                  ),
                                );
                        }),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          SizedBox(width: 14.w),

          // Question counter (e.g. 4/5)
          Text(
            '${controller.currentQuestionNumber}/${controller.totalQuestions}',
            style: GoogleFonts.nunito(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E1B4B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostQuestionCard(QuizQuestionModel question) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main cream question box
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 48.h),
          padding: EdgeInsets.fromLTRB(18.w, 28.h, 18.w, 24.h),
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

        // Gabriel orange label pill attached to top edge
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

        // Gabriel floating character image
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

  Widget _buildOptionsGrid(QuizQuestionModel question) {
    final letters = ['A', 'B', 'C', 'D'];
    final options = question.options;

    return Column(
      children: [
        // Row 1: A and B
        Row(
          children: [
            Expanded(
              child: options.isNotEmpty
                  ? _buildOptionCard(options[0], letters[0])
                  : const SizedBox.shrink(),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: options.length > 1
                  ? _buildOptionCard(options[1], letters[1])
                  : const SizedBox.shrink(),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // Row 2: C and D
        Row(
          children: [
            Expanded(
              child: options.length > 2
                  ? _buildOptionCard(options[2], letters[2])
                  : const SizedBox.shrink(),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: options.length > 3
                  ? _buildOptionCard(options[3], letters[3])
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionCard(QuizOptionModel option, String letter) {
    final isSelected = controller.selectedOptionId.value == option.id;
    final isChecked = controller.isAnswerChecked.value;
    final isCorrectOption =
        isChecked && (controller.correctOptionId.value == option.id ||
            (controller.isAnswerCorrect.value && isSelected));
    final isWrongSelection =
        isChecked && isSelected && !controller.isAnswerCorrect.value;

    Color borderColor;
    double borderWidth = 1.5;
    Widget badge;

    if (isChecked) {
      if (isCorrectOption) {
        borderColor = const Color(0xFF16A34A);
        borderWidth = 2.0;
        badge = Container(
          width: 32.w,
          height: 32.w,
          decoration: const BoxDecoration(
            color: Color(0xFF16A34A),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            ),
          ),
        );
      } else if (isWrongSelection) {
        borderColor = const Color(0xFFEF4444);
        borderWidth = 2.0;
        badge = Container(
          width: 32.w,
          height: 32.w,
          decoration: const BoxDecoration(
            color: Color(0xFFEF4444),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 20,
            ),
          ),
        );
      } else {
        borderColor = const Color(0xFFFED7AA);
        badge = Container(
          width: 32.w,
          height: 32.w,
          decoration: const BoxDecoration(
            color: Color(0xFFFFEDD5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              letter,
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF7C2D12),
              ),
            ),
          ),
        );
      }
    } else {
      if (isSelected) {
        borderColor = const Color(0xFFE06D28);
        borderWidth = 2.0;
        badge = Container(
          width: 32.w,
          height: 32.w,
          decoration: const BoxDecoration(
            color: Color(0xFFE06D28),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              letter,
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        );
      } else {
        borderColor = const Color(0xFFFED7AA);
        badge = Container(
          width: 32.w,
          height: 32.w,
          decoration: const BoxDecoration(
            color: Color(0xFFFFEDD5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              letter,
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF7C2D12),
              ),
            ),
          ),
        );
      }
    }

    return GestureDetector(
      onTap: () => controller.selectOption(option.id),
      child: Container(
        height: 82.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: borderColor,
            width: borderWidth,
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
            badge,
            SizedBox(height: 6.h),
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

  Widget _buildFeedbackMessage() {
    final isCorrect = controller.isAnswerCorrect.value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isCorrect ? '🎉' : '❤️',
          style: TextStyle(fontSize: 18.sp),
        ),
        SizedBox(width: 8.w),
        Text(
          isCorrect
              ? 'Correct! Well done.'
              : 'Nice try! The correct answer is shown',
          style: GoogleFonts.nunito(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4F46E5),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    final isChecked = controller.isAnswerChecked.value;
    final hasSelection = controller.selectedOptionId.value != null;
    final isLast = controller.isLastQuestion;

    String buttonText;
    VoidCallback? onTap;
    Color buttonColor;

    if (!isChecked) {
      buttonText = 'Check Answer';
      if (hasSelection) {
        buttonColor = const Color(0xFFE06D28);
        onTap = controller.checkAnswer;
      } else {
        buttonColor = const Color(0xFFFED7AA);
        onTap = null;
      }
    } else {
      if (isLast) {
        buttonText = 'See Result';
        buttonColor = const Color(0xFFE06D28);
        onTap = controller.seeResult;
      } else {
        buttonText = 'Next Question';
        buttonColor = const Color(0xFFE06D28);
        onTap = controller.nextQuestion;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: hasSelection || isChecked
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
            buttonText,
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
}
