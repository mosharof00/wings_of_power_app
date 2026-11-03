import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GameLeaveConfirmModal extends StatelessWidget {
  const GameLeaveConfirmModal({
    super.key,
    required this.onConfirmLeave,
  });

  final VoidCallback onConfirmLeave;

  static Future<void> show({
    required BuildContext context,
    required VoidCallback onConfirmLeave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GameLeaveConfirmModal(
        onConfirmLeave: () {
          Navigator.of(ctx).pop();
          onConfirmLeave();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 36.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),

          // Title
          Text(
            'Leave the match?',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          SizedBox(height: 8.h),

          // Subtitle
          Text(
            'Your team will keep playing!',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 28.h),

          // Stay Button
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
                'Stay',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Leave Button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: OutlinedButton(
              onPressed: onConfirmLeave,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFE86726),
                side: const BorderSide(color: Color(0xFFFFDFC8), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26.r),
                ),
              ),
              child: Text(
                'Leave',
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
    );
  }
}
