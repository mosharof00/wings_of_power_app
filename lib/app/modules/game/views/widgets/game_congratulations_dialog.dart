import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/global/widgets/app_scaffold.dart';
import 'package:wings_of_power_app/app/global/widgets/app_sunburst_background.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

class GameCongratulationsDialog extends StatelessWidget {
  const GameCongratulationsDialog({
    super.key,
    required this.onPlayNow,
    required this.onHowToPlay,
  });

  final VoidCallback onPlayNow;
  final VoidCallback onHowToPlay;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ClipRect(
            child: AppSunburstBackground(centerAlignment: Alignment(0, -0.3)),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Character with basketball
                      Assets.characters.homePlayGame.image(
                        height: 280.h,
                        fit: BoxFit.contain,
                      ),
                      Transform.translate(
                        offset: Offset(0, -20.h),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 28.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF6EB),
                            borderRadius: BorderRadius.circular(28.r),
                            border: Border.all(
                              color: const Color(0xFFFFDFC8),
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x26000000),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Congratulations!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E1B4B),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'You’ve unlocked the Basketball Game show.\nYou can play the game anytime',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  height: 1.4,
                                  color: const Color(0xFF4B5563),
                                ),
                              ),
                              SizedBox(height: 24.h),
                              // Play Now Button
                              SizedBox(
                                width: double.infinity,
                                height: 52.h,
                                child: ElevatedButton(
                                  onPressed: onPlayNow,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE86726),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(26.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Play Now',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              // How to Play Button
                              SizedBox(
                                width: double.infinity,
                                height: 52.h,
                                child: OutlinedButton(
                                  onPressed: onHowToPlay,
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFFE86726),
                                    side: const BorderSide(
                                      color: Color(0xFFFFDFC8),
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(26.r),
                                    ),
                                  ),
                                  child: Text(
                                    'How to Play',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFE86726),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
