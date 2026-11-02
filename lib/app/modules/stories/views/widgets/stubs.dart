import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/global/widgets/app_text.dart';
import 'package:wings_of_power_app/app/global/widgets/custom_appbar.dart';

/// Placeholder stub for Story Reader mode (T-APP-012).
class StoryReaderStubView extends StatelessWidget {
  const StoryReaderStubView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map? ?? {};
    final storyId = args['storyId'] ?? '';
    final chapterId = args['chapterId'] ?? '';

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: CustomAppBar(
        title: 'Story Reader',
        showBackButton: true,
        onBackTap: () => Get.back(),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                'Reading Mode',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColor.secondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: 8.h),
              AppText(
                'Story: $storyId\nChapter: $chapterId\n\nFull reader flow coming in T-APP-012.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColor.subtitle,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder stub for Story Listening mode (T-APP-013).
class StoryListeningStubView extends StatelessWidget {
  const StoryListeningStubView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map? ?? {};
    final storyId = args['storyId'] ?? '';

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: CustomAppBar(
        title: 'Listen Mode',
        showBackButton: true,
        onBackTap: () => Get.back(),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                'Listening Mode',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColor.secondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: 8.h),
              AppText(
                'Audio for story $storyId\n\nListening flow coming in T-APP-013.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColor.subtitle,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder stub for Chapter Quiz (T-APP-014).
class ChapterQuizStubView extends StatelessWidget {
  const ChapterQuizStubView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map? ?? {};
    final storyId = args['storyId'] ?? '';
    final chapterId = args['chapterId'] ?? '';
    final quizId = args['quizId'] ?? '';

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: CustomAppBar(
        title: 'Chapter Quiz',
        showBackButton: true,
        onBackTap: () => Get.back(),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                'Chapter Quiz',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColor.secondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: 8.h),
              AppText(
                'Quiz: $quizId for chapter $chapterId (story $storyId)\n\nQuiz flow coming in T-APP-014.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColor.subtitle,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
