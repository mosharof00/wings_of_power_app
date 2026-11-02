import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';

class SafeSpaceCategoryCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const SafeSpaceCategoryCard({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  static const Color unselectedBorder = Color(0xFFF4CEB7);
  static const Color selectedBackground = Color(0xFFFFF6ED);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 84.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? selectedBackground : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColor.primary : unselectedBorder,
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? AppColor.primary : AppColor.secondary,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}
