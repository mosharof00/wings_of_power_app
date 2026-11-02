import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/app_text.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

class HomePlayGameBanner extends StatelessWidget {
  const HomePlayGameBanner({
    super.key,
    this.onPlayGame,
  });

  final VoidCallback? onPlayGame;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 160.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFD4B2),
            Color(0xFFFFB27D),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1FEB8940),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Basketball hero on right
          Positioned(
            right: 4.w,
            bottom: 0,
            child: Assets.characters.homePlayGame.image(
              height: 155.h,
              fit: BoxFit.contain,
            ),
          ),
          // Text & button on left
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 128.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  'Ready to Take the Shot?',
                  maxLines: 2,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColor.secondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                        height: 1.15,
                      ),
                ),
                SizedBox(height: 6.h),
                AppText(
                  'Answer questions and show your kindness!',
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColor.secondary.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                        fontSize: 13.sp,
                        height: 1.2,
                      ),
                ),
                SizedBox(height: 10.h),
                GestureDetector(
                  onTap: onPlayGame,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33EE8940),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AppText(
                      'Play Game',
                      style: TextStyle(
                        color: AppColor.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
