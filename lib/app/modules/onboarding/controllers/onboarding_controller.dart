import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/local_store_service.dart';
import '../../../../gen/assets.gen.dart';
import '../../../routes/app_pages.dart';

class OnboardingPage {
  const OnboardingPage({
    required this.image,
    required this.title,
    required this.body,
  });

  final String image;
  final String title;
  final String body;
}

class OnboardingController extends GetxController {
  final page = 0.obs;
  final pageController = PageController();

  final pages = [
    OnboardingPage(
      image: Assets.onboarding.onboardingStories.path,
      title: 'Stories That Inspire',
      body:
          'Read or listen to uplifting stories, learn something new, and discover the power within you.',
    ),
    OnboardingPage(
      image: Assets.onboarding.onboardingSafeSpace.path,
      title: 'Safe Space to Speak Up',
      body:
          'Share your worries or concerns in a private, safe space where your voice matters.',
    ),
    OnboardingPage(
      image: Assets.onboarding.onboardingPlay.path,
      title: 'Learn, Play & Grow',
      body:
          'Answer fun questions, earn Kindness Points, unlock badges, and get ready to play the Basketball Game Show.',
    ),
  ];

  void onPageChanged(int index) => page.value = index;

  void next() {
    if (page.value >= pages.length - 1) {
      finish();
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void finish() {
    HiveService.setOnBoardShowed(true);
    Get.offAllNamed(Routes.WELCOME);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
