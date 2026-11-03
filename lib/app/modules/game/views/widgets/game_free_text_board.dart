import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/data/models/game_match.dart';

class GameFreeTextBoard extends StatelessWidget {
  const GameFreeTextBoard({
    super.key,
    required this.question,
    required this.timerString,
    required this.nickname,
    required this.teamLabel,
    this.avatarUrl,
    required this.textController,
    required this.canSubmit,
    required this.isSubmitted,
    required this.isSubmitting,
    required this.onTextChanged,
    required this.onSubmit,
  });

  final GameQuestionEvent question;
  final String timerString;
  final String nickname;
  final String teamLabel;
  final String? avatarUrl;
  final TextEditingController textController;
  final bool canSubmit;
  final bool isSubmitted;
  final bool isSubmitting;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Header with Avatar, Nickname Prompt, and Timer Pill
          _buildHeader(),
          SizedBox(height: 16.h),

          // 2. Story Prompt
          Text(
            question.prompt.isNotEmpty
                ? question.prompt
                : 'Harold loves science. At lunch, some kids laugh at him and call him a nerd. You are sitting nearby.',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1B4B),
              height: 1.45,
            ),
          ),
          SizedBox(height: 18.h),

          // 3. Question Heading
          Text(
            'What would you do?',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          SizedBox(height: 12.h),

          // 4. Multi-line Text Input
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1.2,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: TextField(
              controller: textController,
              onChanged: onTextChanged,
              enabled: !isSubmitted,
              minLines: 4,
              maxLines: 6,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E1B4B),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Write your answer here......',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // 5. Submit Button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: canSubmit ? onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    canSubmit ? const Color(0xFFE86726) : const Color(0xFFD1D5DB),
                foregroundColor:
                    canSubmit ? Colors.white : const Color(0xFF9CA3AF),
                elevation: canSubmit ? 3 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26.r),
                ),
              ),
              child: isSubmitting
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color:
                            canSubmit ? Colors.white : const Color(0xFF9CA3AF),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Avatar circle
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
          ),
          child: ClipOval(
            child: Image.asset(
              avatarUrl ?? 'assets/images/avatar_01.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.person,
                size: 24,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),

        // Team pill & Nickname prompt
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  teamLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                '$nickname, read the story and share your thoughts',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E1B4B),
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),

        // Clock timer pill (00:60)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3DE),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: const Color(0xFFFFE0B2),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_rounded,
                color: const Color(0xFFE86726),
                size: 16.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                timerString,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

