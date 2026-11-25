import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/theme/app_gradients.dart'
    show AppBackgroundKind;
import 'package:wings_of_power_app/app/global/widgets/app_scaffold.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

import '../controllers/game_mode_select_controller.dart';

class GameModeSelectView extends GetView<GameModeSelectController> {
  const GameModeSelectView({super.key, this.embeddedInTab = false});

  final bool embeddedInTab;

  @override
  Widget build(BuildContext context) {
    final bottomSpace = embeddedInTab
        ? 130.h + MediaQuery.viewPaddingOf(context).bottom
        : 16.h;
    return AppScaffold(
      background: AppBackgroundKind.game,
      body: SafeArea(
        bottom: !embeddedInTab,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, bottomSpace),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  _buildTopBar(),
                  SizedBox(height: 16.h),
                  Image.asset(Assets.logos.gameBanner.path),
                  SizedBox(height: 16.h),
                  _buildUnlockProgress(),
                  SizedBox(height: 16.h),
                  _buildBottomActions(),
                  SizedBox(height: 24.h),
                  const Text(
                    'Select Play Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  _buildPlayModes(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnlockProgress() {
    return Obx(() {
      final eligibility = controller.eligibility.value;
      final unavailable = controller.eligibilityUnavailable.value;
      final progress = eligibility?.progress;
      final rules = eligibility?.rules;
      final quizAverage = progress?.bestQuizPercent
          .toStringAsFixed(2)
          .replaceFirst(RegExp(r'\.?0+$'), '');

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eligibility?.eligible == true && !unavailable
                    ? 'Ready to play!'
                    : 'Unlock progress',
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 6.h),
              if (unavailable)
                Row(
                  children: [
                    const Expanded(
                      child: Text('Couldn’t refresh your progress.'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      onPressed: controller.refreshEligibility,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              if (progress != null && rules != null) ...[
                Text(
                  '${progress.storiesCompleted} / ${rules.requiredStories} stories',
                ),
                Text(
                  'or ${progress.chaptersCompleted} / ${rules.requiredChapters} chapters',
                ),
                SizedBox(height: 6.h),
                Text('Quiz average  $quizAverage% / ${rules.minQuizPercent}%'),
              ] else if (!unavailable)
                const Text('Loading your progress…'),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPlayModes() {
    return Obx(() {
      final selectedSingle = controller.isSinglePlayer.value;
      final busy = controller.isStartingPractice.value;
      final fixtureCode = controller.fixtureCode.value;

      return Column(
        children: [
          SizedBox(
            height: 184.h,
            child: _ModeCard(
              title: busy && selectedSingle
                  ? 'Joining Queue…'
                  : 'Single Player',
              isSelected: selectedSingle,
              onTap: controller.onSinglePlayerCardTap,
              onLongPress: kDebugMode
                  ? controller.onSinglePlayerLongPress
                  : null,
              characterWidget: _buildSinglePlayerArt(),
              extraWidget: fixtureCode == null || fixtureCode.isEmpty
                  ? null
                  : Text(
                      'Fixture: $fixtureCode',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            height: 184.h,
            child: _ModeCard(
              title: busy && !selectedSingle
                  ? 'Joining Queue…'
                  : 'Multi Player',
              isSelected: !selectedSingle,
              onTap: controller.onMultiPlayerCardTap,
              characterWidget: _buildMultiPlayerArt(),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        // Avatar with golden border (Tap to change avatar)
        GestureDetector(
          onTap: controller.onChangeAvatar,
          behavior: HitTestBehavior.opaque,
          child: Obx(() {
            final avatar = controller.avatarUrl.value;
            return Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFA726), width: 2.w),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: avatar != null && avatar.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: avatar,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => Image.asset(
                          'assets/images/avatar_01.png',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        avatar ?? 'assets/images/avatar_01.png',
                        fit: BoxFit.cover,
                      ),
              ),
            );
          }),
        ),
        SizedBox(width: 8.w),
        // Kindness Coins Chip
        Obx(() {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCoinIcon(),
                SizedBox(width: 6.w),
                Text(
                  '${controller.coins.value}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
              ],
            ),
          );
        }),
        SizedBox(width: 8.w),
        // XP Chip
        Obx(() {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBasketballIcon(),
                SizedBox(width: 6.w),
                Text(
                  '${controller.xp.value}XP',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
              ],
            ),
          );
        }),
        SizedBox(width: 8.w),
        // Selected Hero Chip in Header
        Obx(() {
          final hero = controller.selectedHero.value;
          if (hero == null) return const SizedBox.shrink();
          return GestureDetector(
            onTap: controller.onChooseHero,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: const Color(0xFF4C1D95),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFFFD54F), width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    color: const Color(0xFFFFD54F),
                    size: 15.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    hero.displayName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const Spacer(),
        // Home Button
        GestureDetector(
          onTap: controller.onHomeTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 42.w,
            height: 42.w,
            decoration: const BoxDecoration(
              color: Color(0xFFE86726),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(Icons.home_rounded, color: Colors.white, size: 24.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoinIcon() {
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
        ),
      ),
      child: Center(
        child: Icon(Icons.star_rounded, color: Colors.white, size: 15.sp),
      ),
    );
  }

  Widget _buildBasketballIcon() {
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFF7043), Color(0xFFE64A19)],
        ),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(16.w, 16.w),
          painter: _BasketballPainter(),
        ),
      ),
    );
  }



  Widget _buildSinglePlayerArt() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Angel Wings backdrop
        Icon(
          Icons.workspace_premium_rounded,
          color: const Color(0xFFFFD54F).withValues(alpha: 0.35),
          size: 130.sp,
        ),
        // Faith character with basketball
        Assets.characters.homePlayGame.image(
          height: 125.h,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  Widget _buildMultiPlayerArt() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Angel Wings backdrop
        Icon(
          Icons.workspace_premium_rounded,
          color: const Color(0xFFFFD54F).withValues(alpha: 0.35),
          size: 130.sp,
        ),
        // Two heroes side by side
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Assets.characters.homePlayGame.image(
                height: 115.h,
                fit: BoxFit.contain,
              ),
              Transform.translate(
                offset: Offset(-14.w, 0),
                child: Assets.characters.heroHarold.image(
                  height: 112.h,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Row(
      children: [
        // Choose Hero Button
        Expanded(
          child: SizedBox(
            height: 50.h,
            child: ElevatedButton(
              onPressed: controller.onChooseHero,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE86726),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
              child: const Text(
                'Choose Hero',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 14.w),
        // How to Play Button
        Expanded(
          child: SizedBox(
            height: 50.h,
            child: ElevatedButton(
              onPressed: controller.onHowToPlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFE86726),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
              child: Text(
                'How to Play',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE86726),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
    required this.characterWidget,
    this.extraWidget,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget characterWidget;
  final Widget? extraWidget;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26.r),
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFBF4D), Color(0xFFF37526)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0x66F37526)
                  : const Color(0x22000000),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: characterWidget,
                ),
              ),
            ),
            if (extraWidget != null) ...[extraWidget!, SizedBox(height: 6.h)],
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 21.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFFE86726),
                  shadows: isSelected
                      ? const [
                          Shadow(
                            color: Color(0x44000000),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BasketballPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Center vertical and horizontal lines
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), linePaint);
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), linePaint);

    // Curved seams
    final leftSeam = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(cx - r * 0.7, cy), radius: r * 0.7),
        -math.pi / 2,
        math.pi,
      );
    canvas.drawPath(leftSeam, linePaint);

    final rightSeam = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(cx + r * 0.7, cy), radius: r * 0.7),
        math.pi / 2,
        math.pi,
      );
    canvas.drawPath(rightSeam, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
