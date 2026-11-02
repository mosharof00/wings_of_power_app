import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/story_models.dart';
import 'package:wings_of_power_app/app/global/widgets/cached_image.dart';
import 'package:wings_of_power_app/app/global/widgets/error_block.dart';
import '../controllers/reader_controller.dart';
import 'widgets/audio_player_control_box.dart';
import 'widgets/reader_completed_view.dart';
import 'widgets/reader_loading_view.dart';

class StoryListeningView extends GetView<ReaderController> {
  const StoryListeningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const ReaderLoadingView();
      }

      if (controller.isError.value) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColor.secondary),
              onPressed: controller.onBackTap,
            ),
          ),
          body: ErrorBlock(
            message: controller.errorMessage.value,
            onRetry: controller.loadChapter,
          ),
        );
      }

      if (controller.isChapterComplete.value) {
        return ReaderCompletedView(controller: controller);
      }

      final chapter = controller.chapter.value;
      final page = controller.currentPage;

      if (chapter == null || page == null) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: ErrorBlock(
            message: 'No chapter pages available',
            onRetry: controller.loadChapter,
          ),
        );
      }

      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // 1. Top Bar
              _buildTopBar(),

              SizedBox(height: 12.h),

              // 2. Chapter Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  'Chapter ${chapter.chapterNumber}',
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF5B4DBC),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              // 3. Chapter Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  chapter.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    color: AppColor.secondary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              SizedBox(height: 14.h),

              // 4. Page Image Card
              _buildImageCard(page),

              SizedBox(height: 16.h),

              // 5. Page Body Text
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    page.bodyText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      color: const Color(0xFF333333),
                      fontSize: 14.sp,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // 6. Bottom Audio Player Box
              AudioPlayerControlBox(controller: controller),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Circular orange back button
          GestureDetector(
            onTap: controller.onBackTap,
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: const BoxDecoration(
                color: AppColor.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),

          // Read / Listen toggle pill
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEFE6),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => controller.onToggleMode(true),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: controller.isReadMode.value
                          ? AppColor.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Read',
                      style: GoogleFonts.nunito(
                        color: controller.isReadMode.value
                            ? Colors.white
                            : AppColor.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.onToggleMode(false),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: !controller.isReadMode.value
                          ? AppColor.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Listen',
                      style: GoogleFonts.nunito(
                        color: !controller.isReadMode.value
                            ? Colors.white
                            : AppColor.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
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

  Widget _buildImageCard(ChapterPageModel page) {
    return Container(
      width: 296.w,
      height: 292.h,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColor.primary, width: 2.0),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: _buildPageIllustration(page),
      ),
    );
  }

  Widget _buildPageIllustration(ChapterPageModel page) {
    if (page.imageUrl != null && page.imageUrl!.isNotEmpty) {
      if (page.imageUrl!.startsWith('http')) {
        return CachedImage(
          imgUrl: page.imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      }
      return Image.asset(
        page.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    final asset = page.assetPath ?? 'assets/book_covers/page_sample_1.png';
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColor.cream,
          child: const Center(
            child: Icon(Icons.menu_book, color: AppColor.primary, size: 48),
          ),
        );
      },
    );
  }
}
