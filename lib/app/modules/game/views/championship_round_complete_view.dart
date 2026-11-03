import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/models/game_match.dart';
import 'package:wings_of_power_app/app/modules/game/controllers/game_play_controller.dart';
import 'package:wings_of_power_app/app/modules/game/models/game_match_finished.dart';

class ChampionshipRoundCompleteView extends StatelessWidget {
  const ChampionshipRoundCompleteView({
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
            final finished = controller.matchFinished.value;

            // Resolve team A and team B
            final teamA = finished?.teamA ??
                GameMatchFinishedTeam(
                  id: controller.snapshot.value.teams.isNotEmpty
                      ? controller.snapshot.value.teams[0].id
                      : 'team-a',
                  label: controller.getTeamLabel(0),
                  scoreVs: controller.getTeamScore(0),
                  coins: controller.getTeamCoins(0),
                  xp: controller.getTeamScore(0) > 0 ? 2 : 0,
                  members: controller.snapshot.value.teams.isNotEmpty
                      ? controller.snapshot.value.teams[0].members
                      : [],
                );

            final teamB = finished?.teamB ??
                GameMatchFinishedTeam(
                  id: controller.snapshot.value.teams.length > 1
                      ? controller.snapshot.value.teams[1].id
                      : 'team-b',
                  label: controller.getTeamLabel(1),
                  scoreVs: controller.getTeamScore(1),
                  coins: controller.getTeamCoins(1),
                  xp: controller.getTeamScore(1) > 0 ? 2 : 0,
                  members: controller.snapshot.value.teams.length > 1
                      ? controller.snapshot.value.teams[1].members
                      : [],
                );

            final isTie = finished != null
                ? finished.isTie || finished.winnerTeamId == null
                : (teamA.scoreVs == teamB.scoreVs && teamA.coins == teamB.coins);

            final winnerId = isTie ? null : finished?.winnerTeamId;
            final winnerLabel = isTie ? null : finished?.winnerTeamLabel;

            // Check if Team A is winner
            final isWinnerA = !isTie &&
                (winnerId != null
                    ? (teamA.id == winnerId ||
                        (winnerLabel != null &&
                            winnerLabel.toLowerCase() ==
                                teamA.label.toLowerCase()))
                    : (teamA.scoreVs > teamB.scoreVs ||
                        (teamA.scoreVs == teamB.scoreVs &&
                            teamA.coins > teamB.coins)));

            // Check if Team B is winner
            final isWinnerB = !isTie &&
                !isWinnerA &&
                (winnerId != null
                    ? (teamB.id == winnerId ||
                        (winnerLabel != null &&
                            winnerLabel.toLowerCase() ==
                                teamB.label.toLowerCase()))
                    : (teamB.scoreVs > teamA.scoreVs ||
                        (teamB.scoreVs == teamA.scoreVs &&
                            teamB.coins > teamA.coins)));

            // Order cards: winning team card first (if any)
            final List<Widget> cardWidgets = [];
            if (isWinnerB) {
              cardWidgets.add(_ChampionshipTeamCard(
                team: teamB,
                isWinner: true,
              ));
              cardWidgets.add(SizedBox(height: 14.h));
              cardWidgets.add(_ChampionshipTeamCard(
                team: teamA,
                isWinner: false,
              ));
            } else {
              cardWidgets.add(_ChampionshipTeamCard(
                team: teamA,
                isWinner: isWinnerA,
              ));
              cardWidgets.add(SizedBox(height: 14.h));
              cardWidgets.add(_ChampionshipTeamCard(
                team: teamB,
                isWinner: false,
              ));
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 16.h),

                  // 1. Championship Logo & Stars Header
                  _buildChampionshipHeader(),

                  SizedBox(height: 20.h),

                  // 2. Team Cards Container
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: cardWidgets,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // 3. Leaderboard Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton.icon(
                      onPressed: () => controller.onLeaderboardTap(),
                      icon: Icon(
                        Icons.leaderboard_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                      label: Text(
                        'Leaderboard',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0x667C3AED),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // 4. Back to Lobby Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: () => controller.onBackToLobby(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE86726),
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shadowColor: const Color(0x66E86726),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26.r),
                        ),
                      ),
                      child: Text(
                        'Back to Lobby',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildChampionshipHeader() {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Golden Star Glow Aura
        Container(
          width: 260.w,
          height: 140.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFFFD54F).withValues(alpha: 0.55),
                const Color(0xFFF59E0B).withValues(alpha: 0.25),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // 3 Golden Stars Cluster
        Positioned(
          top: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left star
              Transform.rotate(
                angle: -0.18,
                child: Icon(
                  Icons.star_rounded,
                  size: 54.sp,
                  color: const Color(0xFFFFD54F),
                  shadows: const [
                    Shadow(
                      color: Color(0xFFD97706),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),

              // Center star
              Icon(
                Icons.star_rounded,
                size: 88.sp,
                color: const Color(0xFFFFE082),
                shadows: const [
                  Shadow(
                    color: Color(0xFFB45309),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              SizedBox(width: 6.w),

              // Right star
              Transform.rotate(
                angle: 0.18,
                child: Icon(
                  Icons.star_rounded,
                  size: 54.sp,
                  color: const Color(0xFFFFD54F),
                  shadows: const [
                    Shadow(
                      color: Color(0xFFD97706),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Wings of Power & Basketball Edition Ribbon Title
        Padding(
          padding: EdgeInsets.only(top: 60.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Wings of Power stylized text
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.military_tech_rounded,
                    color: const Color(0xFFFFD54F),
                    size: 26.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Wings of Power',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFFFBEB),
                      letterSpacing: 0.5,
                      shadows: const [
                        Shadow(
                          color: Color(0xFF4C1D95),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                        Shadow(
                          color: Color(0xFF1E1B4B),
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.military_tech_rounded,
                    color: const Color(0xFFFFD54F),
                    size: 26.sp,
                  ),
                ],
              ),
              SizedBox(height: 6.h),

              // BASKETBALL EDITION Pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B21A8), Color(0xFF4C1D95)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFFFD54F),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E1B4B).withValues(alpha: 0.6),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'BASKETBALL EDITION',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChampionshipTeamCard extends StatelessWidget {
  const _ChampionshipTeamCard({
    required this.team,
    required this.isWinner,
  });

  final GameMatchFinishedTeam team;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    final title = isWinner ? 'Winner - ${team.label}' : team.label;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8D3),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: "Winner - Team {label}" or "Team {label}"
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2D144B),
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 10.h),

          // Inner White Container
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Roster Row: Student avatars and nicknames (Decision 5: not hero names)
                _buildRosterRow(team.members),

                SizedBox(height: 14.h),

                // Coins & XP Pills Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Kindness Coins Pill
                    _buildKindnessPill(team.coins),

                    SizedBox(width: 14.w),

                    // Basketball XP Pill
                    _buildXpPill(team.xp),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRosterRow(List<GameMatchParticipant> members) {
    if (members.isEmpty) {
      // Default placeholder if roster is empty
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          _ParticipantAvatarItem(
            nickname: 'Student',
            avatarUrl: 'assets/images/avatar_01.png',
          ),
        ],
      );
    }

    if (members.length <= 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: members.map((m) {
          final nick = m.nickname?.isNotEmpty == true
              ? m.nickname!
              : (m.isBot ? 'Practice Bot' : 'Student');
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: _ParticipantAvatarItem(
              nickname: nick,
              avatarUrl: m.avatarUrl,
            ),
          );
        }).toList(),
      );
    }

    // For 5v5 or large teams, horizontally scrollable row
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: members.map((m) {
          final nick = m.nickname?.isNotEmpty == true
              ? m.nickname!
              : (m.isBot ? 'Practice Bot' : 'Student');
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: _ParticipantAvatarItem(
              nickname: nick,
              avatarUrl: m.avatarUrl,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKindnessPill(int coins) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26.w,
            height: 26.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
              ),
            ),
            child: Icon(
              Icons.star_rounded,
              size: 18.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '$coins',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF4C1D95),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXpPill(int xp) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26.w,
            height: 26.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
              ),
            ),
            child: Icon(
              Icons.sports_basketball_rounded,
              size: 17.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '${xp}XP',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF4C1D95),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantAvatarItem extends StatelessWidget {
  const _ParticipantAvatarItem({
    required this.nickname,
    this.avatarUrl,
  });

  final String nickname;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular Avatar with Gold Ring Border
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFFD54F),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: _buildAvatarImage(avatarUrl),
          ),
        ),
        SizedBox(height: 6.h),

        // Student Nickname (Decision 5: not hero name)
        SizedBox(
          width: 60.w,
          child: Text(
            nickname,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E1B4B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarImage(String? url) {
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      }
      final path = url.contains('assets/') ? url : 'assets/images/$url';
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    return Container(
      color: const Color(0xFF8B5CF6),
      child: Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: 28.sp,
      ),
    );
  }
}
