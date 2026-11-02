import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizLeaveDialog extends StatelessWidget {
  const QuizLeaveDialog({
    super.key,
    required this.onKeepGoing,
    required this.onLeave,
  });

  final VoidCallback onKeepGoing;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8EE),
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Right Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: onKeepGoing,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 20.sp,
                    color: const Color(0xFFE5BFA3),
                  ),
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // Title
            Text(
              'Leave the questions?',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E1B4B),
              ),
            ),

            SizedBox(height: 10.h),

            // Subtitle
            Text(
              'Your answers are saved.\nYou can finish later.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4B5563),
                height: 1.4,
              ),
            ),

            SizedBox(height: 24.h),

            // Button 1: Keep Going (Orange)
            GestureDetector(
              onTap: onKeepGoing,
              child: Container(
                width: double.infinity,
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE06D28),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE06D28).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Keep Going',
                    style: GoogleFonts.nunito(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Button 2: Leave for Now (White)
            GestureDetector(
              onTap: onLeave,
              child: Container(
                width: double.infinity,
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: const Color(0xFFFED7AA),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Leave for Now',
                    style: GoogleFonts.nunito(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE06D28),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
