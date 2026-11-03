import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/data/models/game_match.dart';
import '../../controllers/game_play_controller.dart';

class GameQuizBoard extends StatelessWidget {
  const GameQuizBoard({
    super.key,
    required this.question,
    required this.subPhase,
    required this.timerString,
    required this.isYouBuzzed,
    required this.waitingInfo,
    required this.selectedOptionIndex,
    required this.answerResult,
    required this.canPass,
    required this.onBuzzTap,
    required this.onOptionTap,
    required this.onPassTap,
    this.avatarUrl,
    this.isQ3 = false,
    this.hint,
    this.removedOptionIndices = const [],
    this.prismWeights,
    this.powerChips = const [],
    this.canUsePower = false,
    this.hasUsedPower = false,
    this.onUsePower,
  });

  final GameQuestionEvent question;
  final QuestionSubPhase subPhase;
  final String timerString;
  final bool isYouBuzzed;
  final GameWaitingEvent? waitingInfo;
  final int? selectedOptionIndex;
  final GameAnswerResultEvent? answerResult;
  final bool canPass;
  final VoidCallback onBuzzTap;
  final ValueChanged<int> onOptionTap;
  final VoidCallback onPassTap;
  final String? avatarUrl;

  final bool isQ3;
  final String? hint;
  final List<int> removedOptionIndices;
  final List<num>? prismWeights;
  final List<HeroPowerInfo> powerChips;
  final bool canUsePower;
  final bool hasUsedPower;
  final ValueChanged<String>? onUsePower;

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
          // 1. Header (when someone is playing or timer active)
          if (subPhase != QuestionSubPhase.buzzerActive) ...[
            _buildPlayerHeader(),
            SizedBox(height: 12.h),
          ],

          // 2. Progress Dash Row
          _buildProgressRow(),
          SizedBox(height: 16.h),

          // 3. Question Prompt
          Text(
            question.prompt,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E1B4B),
              height: 1.35,
            ),
          ),

          // 3b. Hint Box (if hint sent by server)
          if (hint != null && hint!.trim().isNotEmpty) ...[
            SizedBox(height: 14.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Text(
                'Hint: ${hint!.trim()}',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0369A1),
                  height: 1.4,
                ),
              ),
            ),
          ],

          SizedBox(height: 20.h),

          // 4. Center Area: Buzzer OR Options Grid
          if (subPhase == QuestionSubPhase.buzzerActive ||
              (subPhase == QuestionSubPhase.stealActive &&
                  answerResult?.correct == false &&
                  !isYouBuzzed &&
                  waitingInfo == null)) ...[
            _buildBuzzerCenter(isSteal: subPhase == QuestionSubPhase.stealActive),
          ] else ...[
            _buildOptionsGrid(),
          ],

          SizedBox(height: 20.h),

          // 5. Bottom Action Row / Result Banner
          _buildBottomSection(),

          // 6. Q3 Power Chips Row
          if (isQ3 && powerChips.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildPowerChipsRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerHeader() {
    String titleText = 'Team A';
    String subtitleText = 'You buzzed first!';

    if (isYouBuzzed) {
      titleText = 'Team A';
      subtitleText = 'You buzzed first!';
    } else if (waitingInfo != null) {
      if (waitingInfo!.reason == 'TEAMMATE') {
        titleText = 'Your Teammate is Playing';
        subtitleText = 'Please wait for the result!';
      } else {
        final pName = waitingInfo!.playerName ?? 'Opponent';
        final tLabel = waitingInfo!.teamLabel ?? 'Team B';
        titleText = '$pName from $tLabel is Playing';
        subtitleText = 'Please wait for the result!';
      }
    } else {
      titleText = 'Opponent is Playing';
      subtitleText = 'Please wait for the result!';
    }

    return Row(
      children: [
        // Avatar circle
        Container(
          width: 38.w,
          height: 38.w,
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

        // Text details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
              Text(
                subtitleText,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),

        // Circular Timer Ring
        _buildTimerRing(),
      ],
    );
  }

  Widget _buildTimerRing() {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFF87171),
          width: 3.w,
        ),
      ),
      child: Center(
        child: Text(
          timerString,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E1B4B),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRow() {
    final total = question.total > 0 ? question.total : 5;
    final currentIdx = question.index;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(total, (i) {
              final isFilled = i < currentIdx;
              return Expanded(
                child: Container(
                  height: 6.h,
                  margin: EdgeInsets.only(right: i < total - 1 ? 6.w : 0),
                  decoration: BoxDecoration(
                    color: isFilled
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          '$currentIdx/$total',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E1B4B),
          ),
        ),
      ],
    );
  }

  Widget _buildBuzzerCenter({bool isSteal = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        children: [
          GestureDetector(
            onTap: onBuzzTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFFF7043),
                    Color(0xFFE86726),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x66E86726),
                    blurRadius: 18,
                    spreadRadius: 2,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  isSteal ? 'Steal' : 'Buzz',
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            isSteal ? 'Press first to steal!' : 'Press first to answer',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B21A8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid() {
    final opts = question.options;
    final labels = ['A', 'B', 'C', 'D'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: opts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        // Never hide an option the server did not list
        if (removedOptionIndices.contains(index)) {
          return const Visibility(
            visible: false,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: SizedBox.shrink(),
          );
        }

        final optText = opts[index];
        final label = index < labels.length ? labels[index] : '$index';

        final isChosen = selectedOptionIndex == index;
        final isResult = answerResult != null;
        final isCorrect = answerResult?.correct == true;

        Color borderColor = const Color(0xFFFFDFC8);
        Color badgeBg = const Color(0xFFFFE7D6);
        Color badgeTextColor = const Color(0xFF1E1B4B);
        Widget? badgeIcon;

        if (isResult && isChosen) {
          if (isCorrect) {
            borderColor = const Color(0xFF22C55E);
            badgeBg = const Color(0xFF22C55E);
            badgeIcon = Icon(Icons.check, color: Colors.white, size: 16.sp);
          } else {
            borderColor = const Color(0xFFEF4444);
            badgeBg = const Color(0xFFEF4444);
            badgeIcon = Icon(Icons.close, color: Colors.white, size: 16.sp);
          }
        } else if (isChosen) {
          borderColor = const Color(0xFFE86726);
          badgeBg = const Color(0xFFE86726);
          badgeTextColor = Colors.white;
        }

        final isTappable = isYouBuzzed && selectedOptionIndex == null;

        return GestureDetector(
          onTap: isTappable ? () => onOptionTap(index) : null,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: borderColor, width: isChosen ? 2 : 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Badge circle
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: badgeIcon ??
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: badgeTextColor,
                          ),
                        ),
                  ),
                ),
                SizedBox(height: 6.h),
                // Option text
                Text(
                  optText,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),

                // Prism weights percentage badge
                if (prismWeights != null && index < prismWeights!.length) ...[
                  SizedBox(height: 4.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '${prismWeights![index].toInt()}%',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection() {
    if (answerResult != null) {
      final isCorrect = answerResult!.correct;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isCorrect ? '🎉  Correct! Well done.' : '❤️  Nice try!',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4C1D95),
              ),
            ),
          ],
        ),
      );
    }

    if (subPhase == QuestionSubPhase.buzzedYou ||
        subPhase == QuestionSubPhase.buzzedOther) {
      return Row(
        children: [
          // Pass Now Button
          Expanded(
            child: SizedBox(
              height: 48.h,
              child: ElevatedButton(
                onPressed: canPass ? onPassTap : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canPass
                      ? const Color(0xFFE86726)
                      : const Color(0xFFFFDFC8),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFFFDFC8),
                  disabledForegroundColor: Colors.white70,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pass Now',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    const Icon(Icons.fast_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Next Button (Locked)
          Expanded(
            child: SizedBox(
              height: 48.h,
              child: ElevatedButton(
                onPressed: null, // Always locked during active timer
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFDFC8),
                  disabledBackgroundColor: const Color(0xFFFFDFC8),
                  disabledForegroundColor: Colors.white70,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    const Icon(Icons.lock_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPowerChipsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: powerChips.map((chip) {
          final isTappable = canUsePower && !hasUsedPower;

          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: isTappable
                  ? () => onUsePower?.call(chip.powerCode)
                  : null,
              behavior: HitTestBehavior.opaque,
              child: Opacity(
                opacity: hasUsedPower ? 0.45 : 1.0,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: hasUsedPower
                        ? const Color(0xFFF3F4F6)
                        : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: hasUsedPower
                          ? const Color(0xFFE5E7EB)
                          : const Color(0xFFFFB300),
                      width: 1.4,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar circle
                      Container(
                        width: 26.w,
                        height: 26.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: hasUsedPower
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFFFFB300),
                            width: 1.2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            chip.assetPath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.bolt_rounded,
                              size: 16,
                              color: Color(0xFFE86726),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),

                      // Power label
                      Text(
                        hasUsedPower
                            ? '${chip.powerLabel} (Used)'
                            : chip.powerLabel,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: hasUsedPower
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFFE86726),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
