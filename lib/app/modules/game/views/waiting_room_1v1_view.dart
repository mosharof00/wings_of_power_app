import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/models/hero_models.dart';
import '../controllers/waiting_room_1v1_controller.dart';

typedef GameWaitingRoomView = WaitingRoom1v1View;

class WaitingRoom1v1View extends StatelessWidget {
  WaitingRoom1v1View({
    super.key,
    this.currentUserId,
    this.currentUserNickname,
    this.currentUserAvatar,
    this.selectedHero,
    this.initialTicketId,
    WaitingRoom1v1Controller? controller,
  }) : controller = controller ??
            Get.put(
              WaitingRoom1v1Controller(
                currentUserId: currentUserId,
                currentUserNickname: currentUserNickname,
                currentUserAvatar: currentUserAvatar,
                selectedHero: selectedHero,
                initialTicketId: initialTicketId,
              ),
            );

  final String? currentUserId;
  final String? currentUserNickname;
  final String? currentUserAvatar;
  final HeroModel? selectedHero;
  final String? initialTicketId;
  final WaitingRoom1v1Controller controller;

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
              Color(0xFF7822B7),
              Color(0xFF5D1D9B),
              Color(0xFF4C157E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              // Game Logo
              _buildGameLogo(),
              SizedBox(height: 32.h),
              // Status Header (Title & Subtitle)
              _buildStatusHeader(),
              SizedBox(height: 36.h),
              // Two Seats Cards
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: _buildSeatsRow(),
              ),
              const Spacer(),
              // Action Buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: _buildActionButtons(),
              ),
              SizedBox(height: 36.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              color: const Color(0xFFFFD54F),
              size: 20.sp,
            ),
            SizedBox(width: 4.w),
            Text(
              'Wings of Power',
              style: TextStyle(
                fontFamily: 'LilitaOne',
                fontSize: 26.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFFD54F),
                shadows: const [
                  Shadow(
                    color: Color(0xFF3B0764),
                    offset: Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.auto_awesome,
              color: const Color(0xFFFFD54F),
              size: 20.sp,
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFF4C1D95),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFFFD54F),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'BASKETBALL EDITION',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusHeader() {
    return Obx(() {
      final title = controller.statusTitle.value;
      final subtitle = controller.statusSubtitle.value;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.normal,
              color: const Color(0xFFE9D5FF),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    });
  }

  Widget _buildSeatsRow() {
    return Row(
      children: [
        // Player 1 Card (You)
        Expanded(
          child: _buildSeatCard(
            label: 'Player 1',
            avatarWidget: _buildAvatar(controller.effectiveUserAvatar),
            nameWidget: RichText(
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${controller.effectiveUserNickname} ',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                  TextSpan(
                    text: '(You)',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF27B35),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        // Player 2 Card (Opponent or Waiting)
        Expanded(
          child: Obx(() {
            final isFull = controller.isRoomFull.value;
            final oppNick = controller.opponentNickname.value;
            final oppAvatar = controller.opponentAvatarUrl.value;

            return _buildSeatCard(
              label: 'Player 2',
              avatarWidget: isFull
                  ? _buildAvatar(oppAvatar ?? 'assets/images/avatar_02.png')
                  : _buildWaitingAvatar(),
              nameWidget: Text(
                isFull ? (oppNick ?? 'Classmate') : 'Waiti...',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E1B4B),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSeatCard({
    required String label,
    required Widget avatarWidget,
    required Widget nameWidget,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF27B35),
            ),
          ),
          SizedBox(height: 20.h),
          avatarWidget,
          SizedBox(height: 20.h),
          nameWidget,
        ],
      ),
    );
  }

  Widget _buildAvatar(String avatarUrl) {
    return Container(
      width: 76.w,
      height: 76.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFFFA726),
          width: 2.5.w,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: avatarUrl.startsWith('http')
            ? CachedNetworkImage(
                imageUrl: avatarUrl,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Image.asset(
                  'assets/images/avatar_01.png',
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                avatarUrl.isNotEmpty
                    ? avatarUrl
                    : 'assets/images/avatar_01.png',
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _buildWaitingAvatar() {
    return Container(
      width: 76.w,
      height: 76.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFF9C4),
        border: Border.all(
          color: const Color(0xFFFFD54F),
          width: 2.5.w,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '?',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E1B4B),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      final isFull = controller.isRoomFull.value;
      final isStarting = controller.isStarting.value;

      if (isFull) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Start Game CTA Button
            SizedBox(
              width: 200.w,
              height: 48.h,
              child: ElevatedButton(
                onPressed: isStarting ? null : controller.onStartGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF27B35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  elevation: 4,
                ),
                child: isStarting
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Start Game',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 16.h),
            // Cancel Secondary Button
            GestureDetector(
              onTap: controller.onCancel,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Back to Lobby CTA Button
          SizedBox(
            width: 200.w,
            height: 48.h,
            child: ElevatedButton(
              onPressed: controller.onBackToLobby,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF27B35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                elevation: 4,
              ),
              child: Text(
                'Back to Lobby',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Explore Stories Secondary Button
          GestureDetector(
            onTap: controller.onExploreStories,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
              child: Text(
                'Explore Stories',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
