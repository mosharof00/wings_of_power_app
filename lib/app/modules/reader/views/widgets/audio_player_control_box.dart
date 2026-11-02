import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import '../../controllers/reader_controller.dart';

class AudioPlayerControlBox extends StatelessWidget {
  const AudioPlayerControlBox({
    super.key,
    required this.controller,
  });

  final ReaderController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final position = controller.audioPosition.value;
      final duration = controller.audioDuration.value;
      final isPlaying = controller.isAudioPlaying.value;

      final elapsedStr = controller.formatDuration(position);
      final totalStr = controller.formatDuration(duration);

      final totalSec = duration.inSeconds;
      final currentSec = position.inSeconds;
      final progress = totalSec > 0
          ? (currentSec / totalSec).clamp(0.0, 1.0)
          : 0.0;

      final canRewind = currentSec > 3 || controller.canGoBack;

      return Container(
        margin: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4D6),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Time labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  elapsedStr,
                  style: GoogleFonts.nunito(
                    color: AppColor.secondary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  totalStr,
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF5C5F69),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            SizedBox(height: 6.h),

            // 2. Interactive Scrubber Bar
            LayoutBuilder(
              builder: (context, constraints) {
                final maxW = constraints.maxWidth;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (details) {
                    final dx = details.localPosition.dx.clamp(0.0, maxW);
                    controller.seekToFraction(dx / maxW);
                  },
                  onTapDown: (details) {
                    final dx = details.localPosition.dx.clamp(0.0, maxW);
                    controller.seekToFraction(dx / maxW);
                  },
                  child: Container(
                    height: 18.h,
                    alignment: Alignment.center,
                    child: Container(
                      height: 4.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8D4BF),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: maxW * progress,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: AppColor.primary,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 8.h),

            // 3. Audio Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous track / Rewind
                Semantics(
                  button: true,
                  label: 'Previous',
                  child: GestureDetector(
                    key: const Key('audio_prev_button'),
                    onTap: controller.onPreviousTrackOrRewind,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 6.h,
                      ),
                      child: Icon(
                        Icons.arrow_left,
                        size: 34.sp,
                        color: canRewind
                            ? AppColor.secondary
                            : const Color(0xFFC9C3B4),
                      ),
                    ),
                  ),
                ),

                // Replay 10s
                Semantics(
                  button: true,
                  label: 'Replay 10 seconds',
                  child: GestureDetector(
                    key: const Key('audio_replay_10_button'),
                    onTap: () => controller.skipSeconds(-10),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 6.h,
                      ),
                      child: Icon(
                        Icons.replay_10_rounded,
                        size: 28.sp,
                        color: AppColor.secondary,
                      ),
                    ),
                  ),
                ),

                // Play / Pause Circle
                Semantics(
                  button: true,
                  label: isPlaying ? 'Pause' : 'Play',
                  child: GestureDetector(
                    key: const Key('audio_play_pause_button'),
                    onTap: controller.togglePlayPause,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: const BoxDecoration(
                        color: AppColor.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                    ),
                  ),
                ),

                // Forward 10s
                Semantics(
                  button: true,
                  label: 'Forward 10 seconds',
                  child: GestureDetector(
                    key: const Key('audio_forward_10_button'),
                    onTap: () => controller.skipSeconds(10),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 6.h,
                      ),
                      child: Icon(
                        Icons.forward_10_rounded,
                        size: 28.sp,
                        color: AppColor.secondary,
                      ),
                    ),
                  ),
                ),

                // Next track / Chapter Complete
                Semantics(
                  button: true,
                  label: 'Next',
                  child: GestureDetector(
                    key: const Key('audio_next_button'),
                    onTap: controller.onNextTrackOrSkip,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 6.h,
                      ),
                      child: Icon(
                        Icons.arrow_right,
                        size: 34.sp,
                        color: AppColor.secondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
