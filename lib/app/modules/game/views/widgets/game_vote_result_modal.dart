import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/data/models/game_match.dart';

class GameVoteResultModal extends StatelessWidget {
  const GameVoteResultModal({
    super.key,
    required this.voteResult,
    required this.isRevealed,
    required this.onSeeTheResult,
  });

  final GameVoteResultEvent voteResult;
  final bool isRevealed;
  final VoidCallback onSeeTheResult;

  @override
  Widget build(BuildContext context) {
    final teamLabel = voteResult.teamLabel ?? 'Team A';
    final chosenLetter = voteResult.letter;
    final isCorrect = voteResult.correct;
    final correctLetter = voteResult.correctLetter ?? 'A';
    final correctText = voteResult.correctAnswerText ?? '';

    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 28.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title: Voting Results
                Text(
                  'Voting Results',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                SizedBox(height: 16.h),

                // Choice Line: "Team A chose [A]"
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFDDD6FE)),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$teamLabel chose ',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4C1D95),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            chosenLetter,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                if (!isRevealed) ...[
                  // Unrevealed state: "See the Result!" CTA button (matching q4_vote_waiting_1vote.png)
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: onSeeTheResult,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE86726),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26.r),
                        ),
                      ),
                      child: Text(
                        'See the Result!',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Revealed state (matching q4_vote_waiting_resolved.png)
                  if (correctText.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: const Color(0xFFD8B4FE)),
                      ),
                      child: Text(
                        'Correct Ans: ($correctLetter) $correctText',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF581C87),
                          height: 1.35,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // Correct / Wrong Badge Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isCorrect
                            ? const Color(0xFF86EFAC)
                            : const Color(0xFFFCA5A5),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle_rounded : Icons.favorite_rounded,
                          color: isCorrect ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          isCorrect ? 'Correct! Well done.' : 'Nice try!',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: isCorrect
                                ? const Color(0xFF15803D)
                                : const Color(0xFFB91C1C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

