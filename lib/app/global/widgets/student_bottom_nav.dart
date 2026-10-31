import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/core/theme/app_radius.dart';

import '../../../gen/assets.gen.dart';
import 'app_svg_icon.dart';

/// Orange pill with five icons and no labels.
///
/// Home, stories, badges, and profile report [onTap]. The basketball icon is
/// drawn so the bar matches Home.png. Its tap is reported as index 2 and the
/// shell leaves that handler empty (game plan T-GAME-001).
class StudentBottomNav extends StatelessWidget {
  const StudentBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _labels = ['Home', 'Stories', 'Game', 'Badges', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final icons = [
      Assets.icons.icNavHome,
      Assets.icons.icNavStories,
      Assets.icons.icNavGame,
      Assets.icons.icNavBadges,
      Assets.icons.icNavProfile,
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
        child: Container(
          height: 64.h,
          decoration: BoxDecoration(
            color: AppColor.primary,
            borderRadius: BorderRadius.circular(AppRadius.nav.r),
          ),
          child: Row(
            children: [
              for (var i = 0; i < icons.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: selectedIndex == i,
                    label: _labels[i],
                    child: GestureDetector(
                      key: Key('nav-${_labels[i].toLowerCase()}'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(i),
                      child: Center(
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: selectedIndex == i
                                ? AppColor.white
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: AppSvgIcon(
                            icons[i].path,
                            size: 22.w,
                            color: selectedIndex == i
                                ? AppColor.primary
                                : AppColor.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
