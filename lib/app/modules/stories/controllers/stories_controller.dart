import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/models/story_models.dart';
import 'package:wings_of_power_app/app/data/repositories/story_repository.dart';
import 'package:wings_of_power_app/app/global/widgets/global_snackbar.dart';
import 'package:wings_of_power_app/app/modules/main_page/controllers/main_page_controller.dart';
import 'package:wings_of_power_app/app/routes/app_pages.dart';

class StoriesController extends GetxController {
  StoriesController([IStoryRepository? repository])
      : _repository = repository ?? Get.find<IStoryRepository>();

  final IStoryRepository _repository;

  final stories = <StorySummaryModel>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final isSearchOpen = false.obs;

  final selectedCategory = 'All Category'.obs;
  final selectedAgeGroup = 'All Age Group'.obs;

  static const List<String> categories = [
    'All Category',
    'Kindness',
    'Courage',
    'Cyberbullying',
    'Friendship',
  ];

  static const List<String> ageGroups = [
    'All Age Group',
    'Age 6 to 9',
    'Age 10 to 13',
    'Adults',
  ];

  // Story detail state
  final storyDetail = Rxn<StoryDetailModel>();
  final isDetailLoading = false.obs;
  final detailErrorMessage = ''.obs;
  final selectedDetailTab = 0.obs; // 0: Description, 1: Chapters

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    fetchStories();

    // Check if arguments were passed (e.g. when opened directly to a detail or with a category)
    final args = Get.arguments;
    if (args is Map) {
      if (args['storyId'] is String) {
        fetchStoryDetail(args['storyId'] as String);
      }
      if (args['category'] is String) {
        selectedCategory.value = args['category'] as String;
      }
      if (args['ageGroup'] is String) {
        selectedAgeGroup.value = args['ageGroup'] as String;
      }
    }
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text.trim();
    fetchStories();
  }

  void toggleSearch() {
    isSearchOpen.value = !isSearchOpen.value;
    if (!isSearchOpen.value && searchController.text.isNotEmpty) {
      searchController.clear();
    }
  }

  void setCategory(String category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    fetchStories();
  }

  void setAgeGroup(String ageGroup) {
    if (selectedAgeGroup.value == ageGroup) return;
    selectedAgeGroup.value = ageGroup;
    fetchStories();
  }

  Future<void> fetchStories() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _repository.getStories(
        category: selectedCategory.value,
        ageGroup: selectedAgeGroup.value,
        search: searchQuery.value,
      );
      stories.assignAll(res.items);
    } catch (e) {
      errorMessage.value =
          e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStoryDetail(String storyId) async {
    isDetailLoading.value = true;
    detailErrorMessage.value = '';
    try {
      storyDetail.value = await _repository.getStoryDetail(storyId);
    } catch (e) {
      detailErrorMessage.value =
          e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
    } finally {
      isDetailLoading.value = false;
    }
  }

  void openStoryDetail(String storyId) {
    fetchStoryDetail(storyId);
    selectedDetailTab.value = 0;
    Get.toNamed(Routes.STORY_DETAILS, arguments: {'storyId': storyId});
  }

  void onBack() {
    if (Get.isRegistered<MainPageController>() &&
        Get.find<MainPageController>().selectedIndex.value == 1) {
      Get.find<MainPageController>().changePage(0);
    } else if (Navigator.canPop(Get.context!)) {
      Get.back();
    }
  }

  // --- Reading / Quiz / Listening Navigation ---

  void onStartReading() {
    final story = storyDetail.value;
    if (story == null) return;
    final firstUnlocked = story.chapters.firstWhere(
      (c) => !c.isLocked,
      orElse: () => story.chapters.first,
    );
    Get.toNamed(
      Routes.STORY_READER,
      arguments: {
        'storyId': story.id,
        'chapterId': firstUnlocked.id,
      },
    );
  }

  void onContinueReading() {
    final story = storyDetail.value;
    if (story == null) return;
    final targetChapter = story.currentChapterId != null
        ? story.chapters.firstWhere(
            (c) => c.id == story.currentChapterId,
            orElse: () => story.chapters.first,
          )
        : story.chapters.firstWhere(
            (c) => !c.isLocked,
            orElse: () => story.chapters.first,
          );
    Get.toNamed(
      Routes.STORY_READER,
      arguments: {
        'storyId': story.id,
        'chapterId': targetChapter.id,
      },
    );
  }

  void onListen() {
    final story = storyDetail.value;
    if (story == null) return;
    Get.toNamed(
      Routes.STORY_LISTENING,
      arguments: {
        'storyId': story.id,
      },
    );
  }

  void onChapterTap(ChapterModel chapter) {
    if (chapter.isLocked) {
      globalSnackBar(
        title: 'Chapter Locked',
        message: 'Complete the previous chapter to unlock this one.',
      );
      return;
    }
    final story = storyDetail.value;
    Get.toNamed(
      Routes.STORY_READER,
      arguments: {
        'storyId': story?.id ?? chapter.storyId,
        'chapterId': chapter.id,
      },
    );
  }

  void onQuizTap(ChapterModel chapter) {
    final story = storyDetail.value;
    Get.toNamed(
      Routes.CHAPTER_QUIZ,
      arguments: {
        'storyId': story?.id ?? chapter.storyId,
        'chapterId': chapter.id,
        'quizId': chapter.quizId,
      },
    );
  }
}
