import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GamePowerWingsSheet extends StatelessWidget {
  const GamePowerWingsSheet({super.key});

  static Future<void> show({required BuildContext context}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const GamePowerWingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
}
