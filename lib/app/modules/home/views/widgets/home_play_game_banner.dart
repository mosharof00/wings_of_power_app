import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

/// Full `play_game_card.png` banner. Art already includes copy + CTA.
class HomePlayGameBanner extends StatelessWidget {
  const HomePlayGameBanner({
    super.key,
    this.onPlayGame,
  });

  final VoidCallback? onPlayGame;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPlayGame,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Assets.images.playGameCard.image(
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
