import 'dart:async';

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

  final themes = <StoryThemeModel>[].obs;
  final stories = <StorySummaryModel>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final isSearchOpen = false.obs;

  /// Display label for category pill ("All Category" or theme name).
  final selectedCategoryLabel = 'All Category'.obs;

  /// Selected theme id; null means all themes.
  final selectedThemeId = Rxn<String>();

  final selectedAgeGroupLabel = 'All Age Group'.obs;

  static const List<String> ageGroupLabels = [
    'All Age Group',
    'Age 6 to 9',
    'Age 10 to 13',
    'Adults',
  ];

  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);

    final args = Get.arguments;
    if (args is Map) {
      if (args['themeId'] is String &&
          (args['themeId'] as String).isNotEmpty) {
        selectedThemeId.value = args['themeId'] as String;
      }
      if (args['category'] is String &&
          (args['category'] as String).isNotEmpty) {
        selectedCategoryLabel.value = args['category'] as String;
      }
      if (args['ageGroup'] is String &&
          (args['ageGroup'] as String).isNotEmpty) {
        selectedAgeGroupLabel.value = args['ageGroup'] as String;
      }
      if (args['storyId'] is String) {
        fetchStoryDetail(args['storyId'] as String);
      }
    }

    loadLibrary();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text.trim();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), fetchStories);
  }

  void toggleSearch() {
    isSearchOpen.value = !isSearchOpen.value;
    if (!isSearchOpen.value && searchController.text.isNotEmpty) {
      searchController.clear();
    }
  }

  List<String> get categoryFilterOptions {
    return [
      'All Category',
      ...themes.map((t) => t.name),
    ];
  }

  void setCategoryLabel(String label) {
    if (selectedCategoryLabel.value == label) return;
    selectedCategoryLabel.value = label;
    if (label == 'All Category') {
      selectedThemeId.value = null;
    } else {
      StoryThemeModel? match;
      for (final t in themes) {
        if (t.name == label) {
          match = t;
          break;
        }
      }
      selectedThemeId.value = match?.id;
    }
    fetchStories();
  }

  void setAgeGroupLabel(String label) {
    if (selectedAgeGroupLabel.value == label) return;
    selectedAgeGroupLabel.value = label;
    fetchStories();
  }

  String? get _apiAgeGroup {
    final label = selectedAgeGroupLabel.value;
    if (label == 'All Age Group') return null;
    if (label == 'Age 6 to 9') return 'AGE_6_9';
    if (label == 'Age 10 to 13') return 'AGE_10_13';
    if (label == 'Adults') return 'ADULTS';
    return null;
  }

  String? get _apiCategorySlug {
    if (selectedThemeId.value != null) return null;
    final label = selectedCategoryLabel.value;
    if (label == 'All Category') return null;
    for (final t in themes) {
      if (t.name == label) return t.slug;
    }
    return label.toLowerCase();
  }

  Future<void> loadLibrary() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final themeRows = await _repository.getThemes();
      themes.assignAll(themeRows);

      // Resolve themeId from a name/slug/id passed from Home.
      if (selectedThemeId.value == null &&
          selectedCategoryLabel.value != 'All Category') {
        final label = selectedCategoryLabel.value.toLowerCase();
        StoryThemeModel? match;
        for (final t in themeRows) {
          if (t.name.toLowerCase() == label ||
              t.slug.toLowerCase() == label ||
              t.id == selectedCategoryLabel.value) {
            match = t;
            break;
          }
        }
        if (match != null) {
          selectedThemeId.value = match.id;
          selectedCategoryLabel.value = match.name;
        }
      } else if (selectedThemeId.value != null) {
        for (final t in themeRows) {
          if (t.id == selectedThemeId.value) {
            selectedCategoryLabel.value = t.name;
            break;
          }
        }
      }

      await fetchStories(showLoading: false);
    } catch (e) {
      errorMessage.value =
          e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStories({bool showLoading = true}) async {
    if (showLoading) isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _repository.getStories(
        themeId: selectedThemeId.value,
        category: _apiCategorySlug,
        ageGroup: _apiAgeGroup,
        search: searchQuery.value,
        perPage: 50,
      );
      stories.assignAll(res.items);
    } catch (e) {
      errorMessage.value =
          e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  /// Sections for "All Category" mode: one row per active theme that has stories.
  List<({StoryThemeModel theme, List<StorySummaryModel> stories})>
      get themeSections {
    final sections =
        <({StoryThemeModel theme, List<StorySummaryModel> stories})>[];
    for (final theme in themes) {
      final rows = stories
          .where(
            (s) =>
                s.themeId == theme.id ||
                s.category.toLowerCase() == theme.slug.toLowerCase(),
          )
          .toList();
      if (rows.isNotEmpty) {
        sections.add((theme: theme, stories: rows));
      }
    }
    // Orphan stories (unknown theme) — keep visible.
    final knownIds = themes.map((t) => t.id).toSet();
    final knownSlugs = themes.map((t) => t.slug.toLowerCase()).toSet();
    final orphans = stories
        .where(
          (s) =>
              (s.themeId == null || !knownIds.contains(s.themeId)) &&
              !knownSlugs.contains(s.category.toLowerCase()),
        )
        .toList();
    if (orphans.isNotEmpty) {
      sections.add((
        theme: const StoryThemeModel(
          id: '_other',
          name: 'Other',
          slug: 'other',
        ),
        stories: orphans,
      ));
    }
    return sections;
  }

  List<StorySummaryModel> storiesForAgeBand(String apiAge) {
    return stories.where((s) {
      final ag = s.ageGroup.toUpperCase();
      if (apiAge == 'AGE_6_9') {
        return ag == 'AGE_6_9' || ag == '6-9' || ag.contains('6');
      }
      if (apiAge == 'AGE_10_13') {
        return ag == 'AGE_10_13' || ag == '10-13' || ag.contains('10');
      }
      if (apiAge == 'ADULTS') {
        return ag == 'ADULTS' || ag.contains('ADULT') || ag.contains('14');
      }
      return false;
    }).toList();
  }

  // Story detail state
  final storyDetail = Rxn<StoryDetailModel>();
  final isDetailLoading = false.obs;
  final detailErrorMessage = ''.obs;
  final selectedDetailTab = 0.obs;

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
