import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/network/api_client.dart';
import 'package:wings_of_power_app/app/core/services/local_store_service.dart';
import 'package:wings_of_power_app/app/data/models/home_models.dart';
import 'package:wings_of_power_app/app/data/repositories/game_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/home_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/igame_repository.dart';
import 'package:wings_of_power_app/app/modules/game/views/widgets/game_congratulations_dialog.dart';
import 'package:wings_of_power_app/app/modules/game/views/widgets/game_how_to_play_sheet.dart';
import 'package:wings_of_power_app/app/modules/game/views/widgets/game_unlock_dialog.dart';
import 'package:wings_of_power_app/app/modules/main_page/controllers/main_page_controller.dart';
import 'package:wings_of_power_app/app/routes/app_pages.dart';

class HomeController extends GetxController {
  HomeController([
    IHomeRepository? repository,
    IGameRepository? gameRepository,
  ])  : _repository = repository ?? Get.find<IHomeRepository>(),
        _gameRepository = gameRepository;

  final IHomeRepository _repository;
  final IGameRepository? _gameRepository;

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

  IGameRepository get _effectiveGameRepo {
    final repo = _gameRepository;
    if (repo != null) return repo;
    if (Get.isRegistered<IGameRepository>()) return Get.find<IGameRepository>();
    if (Get.isRegistered<ApiClient>()) {
      return GameRepository(Get.find<ApiClient>());
    }
    return GameRepository(ApiClient());
  }

  /// Filled by T-GAME-001 (owns eligibility, Game show modal, mode select).
  Future<void> onPlayGame() async {
    try {
      final gameRepo = _effectiveGameRepo;
      final eligibility = await gameRepo.getEligibility();

      if (!eligibility.eligible) {
        Get.dialog(
          GameUnlockDialog(
            eligibility: eligibility,
            onContinueReading: () {
              Get.back();
              _openStoryLibrary();
            },
          ),
          barrierDismissible: true,
        );
      } else {
        final congratsShown =
            HiveService.read<bool>('game_congrats_shown') ?? false;
        if (!congratsShown) {
          HiveService.write('game_congrats_shown', true);
          Get.dialog(
            GameCongratulationsDialog(
              onPlayNow: () {
                Get.back();
                Get.toNamed(Routes.GAME_MODE_SELECT);
              },
              onHowToPlay: () async {
                final howToPlay = await gameRepo.getHowToPlay();
                await GameHowToPlaySheet.show(howToPlay: howToPlay);
              },
            ),
            barrierDismissible: true,
          );
        } else {
          Get.toNamed(Routes.GAME_MODE_SELECT);
        }
      }
    } catch (_) {
      Get.dialog(
        GameUnlockDialog(
          eligibility: GameRepository.getMockEligibility(eligible: false),
          onContinueReading: () {
            Get.back();
            _openStoryLibrary();
          },
        ),
        barrierDismissible: true,
      );
    }
  }

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
