import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/data/models/game_match.dart';

class GamePowerWingsSheet extends StatelessWidget {
  const GamePowerWingsSheet({
    super.key,
    this.isQ3 = false,
    this.snapshot,
    this.currentUserId,
    this.youParticipantId,
  });

  final bool isQ3;
  final GameMatchSnapshot? snapshot;
  final String? currentUserId;
  final String? youParticipantId;

  static Future<void> show({
    required BuildContext context,
    bool isQ3 = false,
    GameMatchSnapshot? snapshot,
    String? currentUserId,
    String? youParticipantId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GamePowerWingsSheet(
        isQ3: isQ3,
        snapshot: snapshot,
        currentUserId: currentUserId,
        youParticipantId: youParticipantId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isQ3) {
      return _buildNotAvailableSheet(context);
    }
    return _buildQ3PowersSheet(context);
  }

  Widget _buildNotAvailableSheet(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 36.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),

          Container(
            width: 60.w,
            height: 60.w,
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bolt_rounded,
              color: const Color(0xFFF59E0B),
              size: 36.sp,
            ),
          ),
          SizedBox(height: 16.h),

          Text(
            'Team Power Wings',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          SizedBox(height: 8.h),

          Text(
            'Not Available!\nPowers unlock in Quarter 3 (Hobby Hoops).',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          SizedBox(height: 28.h),

          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE86726),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26.r),
                ),
              ),
              child: Text(
                'Keep Playing',
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
    );
  }

  Widget _buildQ3PowersSheet(BuildContext context) {
    final participants = snapshot?.allParticipants ?? [];

    return Container(
      constraints: BoxConstraints(maxHeight: 0.85.sh),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 44.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),

          // Header Row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE86726),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Team Power Wings',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
              ),
              SizedBox(width: 36.w), // Balance back button
            ],
          ),
          SizedBox(height: 16.h),

          // List of Power Cards
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: participants.isNotEmpty ? participants.length : 1,
              separatorBuilder: (context, index) => SizedBox(height: 14.h),
              itemBuilder: (context, index) {
                if (participants.isEmpty) {
                  return _buildPowerCard(
                    heroInfo: HeroPowerInfo.findByPowerCode('LAB')!,
                    participant: GameMatchParticipant(
                      id: youParticipantId ?? 'part-you-1',
                      userId: currentUserId,
                      nickname: 'You',
                      powerUsed: false,
                    ),
                    isYou: true,
                  );
                }

                final p = participants[index];
                final isYou = (p.userId != null && p.userId == currentUserId) ||
                    (p.id != null && p.id == youParticipantId);

                final heroInfo = HeroPowerInfo.findByPowerCode(p.powerCode) ??
                    HeroPowerInfo.findByHeroIdOrCode(p.heroId) ??
                    HeroPowerInfo.findByPowerCode(
                        isYou ? snapshot?.you?.powerCode : null) ??
                    const HeroPowerInfo(
                      heroCode: 'HAROLD',
                      heroName: 'Harold',
                      powerCode: 'LAB',
                      powerLabel: 'Lab Shot',
                      description: 'Removes 2 wrong answer',
                      bannerTitle: 'Smart move!',
                      bannerSubtitle: 'Science to the rescue! Two options eliminated!',
                      assetPath: 'assets/characters/hero_harold.png',
                    );

                final bool hasUsed = isYou
                    ? (snapshot?.you?.powerUsed ?? p.powerUsed)
                    : p.powerUsed;

                return _buildPowerCard(
                  heroInfo: heroInfo,
                  participant: p,
                  isYou: isYou,
                  powerUsed: hasUsed,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerCard({
    required HeroPowerInfo heroInfo,
    required GameMatchParticipant participant,
    required bool isYou,
    bool powerUsed = false,
  }) {
    final displayName = isYou ? 'You' : (participant.nickname ?? 'Player');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Hero Circle
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFB300), width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                heroInfo.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.sports_basketball,
                  color: Color(0xFFE86726),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),

          // Power Name
          Text(
            heroInfo.powerLabel,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE86726),
            ),
          ),
          SizedBox(height: 4.h),

          // Description
          Text(
            heroInfo.description,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 12.h),

          // Participant Holder Pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: powerUsed ? const Color(0xFFF3F4F6) : const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: powerUsed
                    ? const Color(0xFFE5E7EB)
                    : const Color(0xFFBAE6FD),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar circle
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: powerUsed
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFFFFB300),
                      width: 1.2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      participant.avatarUrl ?? 'assets/images/avatar_01.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.person,
                        size: 16.sp,
                        color: powerUsed
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF0369A1),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // Name & used label
                Text(
                  powerUsed ? '$displayName (Used)' : displayName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: powerUsed
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF0369A1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
