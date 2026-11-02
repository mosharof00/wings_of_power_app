import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/models/home_models.dart';
import 'package:wings_of_power_app/app/data/repositories/home_repository.dart';
import 'package:wings_of_power_app/app/modules/main_page/controllers/main_page_controller.dart';
import 'package:wings_of_power_app/app/routes/app_pages.dart';

class HomeController extends GetxController {
  HomeController([IHomeRepository? repository])
      : _repository = repository ?? Get.find<IHomeRepository>();

  final IHomeRepository _repository;

  final homeData = Rxn<HomeDataModel>();
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    fetchHome();
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text.trim();
  }

  Future<void> fetchHome() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      homeData.value = await _repository.getHome();
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
    } finally {
      isLoading.value = false;
    }
  }

  List<HomeStoryModel> get filteredPopularStories {
    final stories = homeData.value?.popularStories ?? [];
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) return stories;
    return stories.where((story) {
      final matchesTitle = story.title.toLowerCase().contains(query);
      final matchesSubtitle =
          story.subtitle?.toLowerCase().contains(query) ?? false;
      return matchesTitle || matchesSubtitle;
    }).toList();
  }

  HomeBannerModel? get banner => homeData.value?.banner;
  List<HomeCategoryModel> get categories => homeData.value?.categories ?? [];
  int get points => homeData.value?.points ?? 0;
  String get greeting => homeData.value?.greeting ?? 'Hey Sarah!';
  String get subtitle => homeData.value?.subtitle ?? 'Ready to learn today?';
  String? get avatarUrl => homeData.value?.avatarUrl;

  /// Filled by T-GAME-001 (owns eligibility, Game show modal, mode select).
  void onPlayGame() {}

  /// Navigates to story library (tab index 1 in MainPage).
  void onStartReading() => _openStoryLibrary();

  /// Navigates to continue reading (story library or reader in T-APP-011 / T-APP-012).
  void onContinueReading() => _openStoryLibrary();

  /// Navigates to quiz (T-APP-014 / story library).
  void onTakeQuiz() => _openStoryLibrary();

  /// Navigates to story library (See all).
  void onSeeAllStories() => _openStoryLibrary();

  /// Navigates to stories filtered by category.
  void onCategoryTap(HomeCategoryModel category) => _openStoryLibrary();

  /// Navigates to story details.
  void onStoryTap(HomeStoryModel story) => _openStoryLibrary();

  /// Safe Space Report opens T-APP-016 placeholder stub.
  void onSafeSpaceReport() {
    Get.toNamed(Routes.SAFE_SPACE_REPORT);
  }

  /// Notification Bell has no route (D14).
  void onBellTap() {}

  /// Kindness Corner has no route (D14).
  void onKindnessCornerTap() {}

  /// Audio Books has no route (D14).
  void onAudioBooksTap() {}

  void _openStoryLibrary() {
    if (Get.isRegistered<MainPageController>()) {
      Get.find<MainPageController>().changePage(1);
    }
  }
}
