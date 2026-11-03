import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/data/models/game_match.dart';

class GameRoundIntroCard extends StatelessWidget {
  const GameRoundIntroCard({
    super.key,
    this.introEvent,
    required this.onOpenQuiz,
  });

  final GameRoundIntroEvent? introEvent;
  final VoidCallback onOpenQuiz;

  @override
  Widget build(BuildContext context) {
    final roundType = introEvent?.roundType ?? 'Q1_WARMUP';

    final String roundSubtitle;
    final String defaultTitle;
    final String defaultBlurb;
    final String buttonLabel;

    switch (roundType) {
      case 'Q2_DEFENSE':
        roundSubtitle = 'Round 2';
        defaultTitle = 'Defense Round';
        defaultBlurb = 'Share your kindness. There are no wrong answers.';
        buttonLabel = 'Read the Story';
        break;
      case 'Q3_HOBBY':
        roundSubtitle = 'Round 3';
        defaultTitle = 'Hobby Hoops';
        defaultBlurb = 'Use your Power Wing once to help your team';
        buttonLabel = 'Open Your Quiz';
        break;
      case 'Q4_FINALS':
        roundSubtitle = 'Round 4';
        defaultTitle = 'Wings Final';
        defaultBlurb = 'Share your thoughts. Baskets are worth 3 points';
        buttonLabel = 'Start Championship';
        break;
      case 'Q1_WARMUP':
      default:
        roundSubtitle = 'Round 1';
        defaultTitle = 'Warm-Up Hoops';
        defaultBlurb = 'Answer fast and earn balls for the Shootout';
        buttonLabel = 'Open Your First Quiz';
        break;
    }

    final title = introEvent?.title ?? defaultTitle;
    final blurb = introEvent?.blurb ?? defaultBlurb;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF7822B7),
            Color(0xFF5D1D9B),
            Color(0xFF4C157E),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Main White Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(24.w, 64.h, 24.w, 32.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      roundSubtitle,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E1B4B),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      blurb,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 36.h),
                    SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: ElevatedButton(
                        onPressed: onOpenQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE86726),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27.r),
                          ),
                        ),
                        child: Text(
                          buttonLabel,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Emblem overflowing top
              Positioned(
                top: -38.h,
                child: _buildEmblem(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmblem() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF6B21A8),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFFFD54F), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.sports_basketball,
            color: Color(0xFFFF9800),
            size: 26,
          ),
          SizedBox(width: 8.w),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WINGS OF POWER',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFFD54F),
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'BASKETBALL EDITION',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
