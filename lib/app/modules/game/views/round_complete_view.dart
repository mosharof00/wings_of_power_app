import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/models/game_match.dart';
import 'package:wings_of_power_app/app/modules/game/controllers/game_play_controller.dart';

class RoundCompleteView extends StatelessWidget {
  const RoundCompleteView({
    super.key,
    required this.controller,
  });

  final GamePlayController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5B21B6),
              Color(0xFF4C1D95),
              Color(0xFF3B0764),
              Color(0xFF1E1B4B),
            ],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            final rc = controller.roundComplete.value;
            final roundNum = rc?.roundNumber ?? 1;

            final teamA = rc?.teamA ??
                GameRoundTeamSummary(
                  name: controller.getTeamLabel(0),
                  scoreVs: controller.getTeamScore(0),
                  coins: 245,
                  xp: controller.getTeamScore(0) > 0 ? 2 : 0,
                );

            final teamB = rc?.teamB ??
                GameRoundTeamSummary(
                  name: controller.getTeamLabel(1),
                  scoreVs: controller.getTeamScore(1),
                  coins: 245,
                  xp: controller.getTeamScore(1) > 0 ? 2 : 0,
                );

            final isSubmitting = controller.isSubmittingAck.value;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 24.h),

                  // 1. Golden Star Cluster & Title Banner
                  _buildStarsAndRibbon(roundNum),

                  SizedBox(height: 28.h),

                  // 2. Team Cards Container
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Team A Card
                            _TeamScoreCard(
                              teamLetter: 'A',
                              teamName: teamA.name.isNotEmpty ? teamA.name : 'Team A',
                              scoreVs: teamA.scoreVs,
                              coins: teamA.coins,
                              xp: teamA.xp,
                            ),
                            SizedBox(height: 16.h),

                            // Team B Card (rendered with Team B even though PNG had Team A twice per D23)
                            _TeamScoreCard(
                              teamLetter: 'B',
                              teamName: teamB.name.isNotEmpty ? teamB.name : 'Team B',
                              scoreVs: teamB.scoreVs,
                              coins: teamB.coins,
                              xp: teamB.xp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. Play Next Round Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () => controller.onPlayNextRoundTap(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE86726),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            const Color(0xFFE86726).withValues(alpha: 0.6),
                        elevation: 6,
                        shadowColor: const Color(0x66E86726),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26.r),
                        ),
                      ),
                      child: isSubmitting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'Waiting for next round...',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Play Next Round',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 28.h),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStarsAndRibbon(int roundNum) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Golden Star Glow Aura
        Container(
          width: 220.w,
          height: 120.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFFFD54F).withValues(alpha: 0.45),
                const Color(0xFFF59E0B).withValues(alpha: 0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // 3 Golden Stars Cluster
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Left smaller star
            Transform.rotate(
              angle: -0.15,
              child: Icon(
                Icons.star_rounded,
                size: 50.sp,
                color: const Color(0xFFFFD54F),
                shadows: const [
                  Shadow(
                    color: Color(0xFFD97706),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
            SizedBox(width: 4.w),

            // Center large star
            Icon(
              Icons.star_rounded,
              size: 88.sp,
              color: const Color(0xFFFFD54F),
              shadows: const [
                Shadow(
                  color: Color(0xFFD97706),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            SizedBox(width: 4.w),

            // Right smaller star
            Transform.rotate(
              angle: 0.15,
              child: Icon(
                Icons.star_rounded,
                size: 50.sp,
                color: const Color(0xFFFFD54F),
                shadows: const [
                  Shadow(
                    color: Color(0xFFD97706),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Folded Purple Ribbon across the stars
        Positioned(
          bottom: -14.h,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFA855F7),
                  Color(0xFF9333EA),
                  Color(0xFF7E22CE),
                ],
              ),
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x667E22CE),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Round $roundNum Completed',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.4,
                shadows: const [
                  Shadow(
                    color: Color(0x66000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Team Score Row Card matching design/screens/game/round_complete/round_complete_summary.png
class _TeamScoreCard extends StatelessWidget {
  const _TeamScoreCard({
    required this.teamLetter,
    required this.teamName,
    required this.scoreVs,
    required this.coins,
    required this.xp,
  });

  final String teamLetter;
  final String teamName;
  final int scoreVs;
  final int coins;
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Letter Avatar Circle
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFD54F),
                width: 2.2,
              ),
            ),
            child: Center(
              child: Text(
                teamLetter,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
            ),
          ),
          SizedBox(width: 14.w),

          // Team Details: Label & Metric Pills
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      teamName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E1B4B),
                      ),
                    ),
                    // Vs score pill
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: const Color(0xFFF59E0B),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        'Vs: $scoreVs',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Row of Coins & XP Pills
                Row(
                  children: [
                    // Kindness Coins Pill
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.monetization_on,
                            size: 18.sp,
                            color: const Color(0xFFF59E0B),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '$coins',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1E1B4B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10.w),

                    // XP Pill
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sports_basketball,
                            size: 18.sp,
                            color: const Color(0xFFEA580C),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '${xp}XP',
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
