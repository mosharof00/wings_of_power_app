import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/game_help_events.dart';

class GameTeammateSuggestModal extends StatefulWidget {
  const GameTeammateSuggestModal({
    super.key,
    required this.helpRequest,
    required this.onSuggest,
    this.onDismiss,
  });

  final GameHelpRequestEvent helpRequest;
  final ValueChanged<int> onSuggest;
  final VoidCallback? onDismiss;

  @override
  State<GameTeammateSuggestModal> createState() =>
      _GameTeammateSuggestModalState();
}

class _GameTeammateSuggestModalState extends State<GameTeammateSuggestModal> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final requester = widget.helpRequest.fromNickname ?? 'Your teammate';
    final opts = widget.helpRequest.options;
    const labels = ['A', 'B', 'C', 'D'];

    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Blurred background
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: const Color(0x99000000),
                ),
              ),
            ),
          ),

          // Dialog Card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(22.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x44000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Row with close
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFFFB300)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.favorite_rounded,
                              color: Color(0xFFE86726),
                              size: 14,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Harmony Help',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFE86726),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onDismiss,
                        child: Icon(
                          Icons.close_rounded,
                          size: 24.sp,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Header title & prompt
                  Text(
                    '$requester is asking for help!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Suggest an answer to help your teammate:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Options Grid / List
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: opts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: 1.25,
                    ),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIndex == index;
                      final label =
                          index < labels.length ? labels[index] : '$index';
                      final text = opts[index];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFFF7ED)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFE86726)
                                  : const Color(0xFFFFDFC8),
                              width: isSelected ? 2 : 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24.w,
                                height: 24.w,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFE86726)
                                      : const Color(0xFFFFE7D6),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF1E1B4B),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                text,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E1B4B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),

                  // Submit suggestion button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: _selectedIndex != null
                          ? () => widget.onSuggest(_selectedIndex!)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE86726),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFFFDFC8),
                        disabledForegroundColor: Colors.white70,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                      child: Text(
                        'Send Suggestion',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }
}
