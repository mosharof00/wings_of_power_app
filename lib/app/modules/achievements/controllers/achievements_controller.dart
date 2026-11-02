import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/network/api_exception.dart';
import 'package:wings_of_power_app/app/core/utils/logger.dart';
import 'package:wings_of_power_app/app/data/models/achievement_models.dart';
import 'package:wings_of_power_app/app/data/repositories/achievement_repository.dart';
import 'package:wings_of_power_app/app/modules/main_page/controllers/main_page_controller.dart';
import 'package:wings_of_power_app/app/routes/app_pages.dart';

import '../views/widgets/badge_how_to_sheet.dart';
import '../views/widgets/badge_unlock_dialog.dart';

class AchievementsController extends GetxController {
  final IAchievementRepository _repository;

  AchievementsController(this._repository);

  // ── Badges State ─────────────────────────────────────────────────────────
  final isBadgesLoading = false.obs;
  final badgesError = ''.obs;
  final badges = <BadgeModel>[].obs;
  final earnedCount = 6.obs;
  final totalCount = 6.obs;
  final points = 248.obs;
  final fixtureState = 'all_earned'.obs;

  // ── Positive Points State ─────────────────────────────────────────────────
  final isPointsLoading = false.obs;
  final pointsError = ''.obs;
  final totalPoints = 245.obs;
  final todayPoints = 30.obs;
  final pointItems = <PointLedgerItemModel>[].obs;

  // ── Leaderboard State ────────────────────────────────────────────────────
  final isLeaderboardLoading = false.obs;
  final leaderboardError = ''.obs;
  final podium = <LeaderboardItemModel>[].obs;
  final rankedList = <LeaderboardItemModel>[].obs;
  final currentStudent = Rxn<LeaderboardItemModel>();
  final leaderboardScope = 'class'.obs;

  // ── Reading Progress State ────────────────────────────────────────────────
  final isReadingProgressLoading = false.obs;
  final readingProgressError = ''.obs;
  final overallPercent = 60.obs;
  final statusMessage = 'Keep reading!'.obs;
  final storiesCompleted = 1.obs;
  final storiesTotal = 8.obs;
  final quizScoreMean = 52.obs;
  final streakDays = 5.obs;
  final chapterProgressList = <ChapterProgressItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBadges();
    fetchPoints();
    fetchLeaderboard();
    fetchReadingProgress();
  }

  // ── Badges Actions ───────────────────────────────────────────────────────
  Future<void> fetchBadges({String? fixture}) async {
    isBadgesLoading.value = true;
    badgesError.value = '';
    final state = fixture ?? fixtureState.value;
    try {
      final response = await _repository.getBadges(fixtureState: state);
      badges.assignAll(response.badges);
      earnedCount.value = response.earnedCount;
      totalCount.value = response.totalCount;
      points.value = response.points;
    } catch (e) {
      Log.e('Failed to fetch badges: $e');
      badgesError.value = e is ApiException ? e.message : 'Failed to load badges';
    } finally {
      isBadgesLoading.value = false;
    }
  }

  void setFixtureState(String state) {
    fixtureState.value = state;
    fetchBadges(fixture: state);
  }

  void onBadgeTap(BuildContext context, BadgeModel badge) {
    if (!badge.isEarned) {
      // Locked badge -> how-to sheet
      showBadgeHowToSheet(context, badge);
    } else {
      // Earned badge -> celebration / detail dialog
      showBadgeCelebrationDialog(context, badge: badge);
    }
  }

  void showUnlockNotificationModal(BuildContext context, BadgeModel badge) {
    showBadgeNotificationDialog(context, badge: badge);
  }

  // ── Positive Points Actions ──────────────────────────────────────────────
  Future<void> fetchPoints({bool empty = false}) async {
    isPointsLoading.value = true;
    pointsError.value = '';
    try {
      if (empty) {
        pointItems.clear();
        totalPoints.value = 0;
        todayPoints.value = 0;
      } else {
        final response = await _repository.getStudentPoints();
        totalPoints.value = response.totalPoints;
        todayPoints.value = response.todayPoints;
        pointItems.assignAll(response.items);
      }
    } catch (e) {
      Log.e('Failed to fetch points: $e');
      pointsError.value = e is ApiException ? e.message : 'Failed to load points';
    } finally {
      isPointsLoading.value = false;
    }
  }

  // ── Leaderboard Actions ──────────────────────────────────────────────────
  Future<void> fetchLeaderboard([String scope = 'class']) async {
    isLeaderboardLoading.value = true;
    leaderboardError.value = '';
    leaderboardScope.value = scope;
    try {
      final response = await _repository.getStudentLeaderboard(scope: scope);
      podium.assignAll(response.podium);
      rankedList.assignAll(response.rankedList);
      currentStudent.value = response.currentStudent;
    } catch (e) {
      Log.e('Failed to fetch leaderboard: $e');
      leaderboardError.value =
          e is ApiException ? e.message : 'Failed to load leaderboard';
    } finally {
      isLeaderboardLoading.value = false;
    }
  }

  // ── Reading Progress Actions ─────────────────────────────────────────────
  Future<void> fetchReadingProgress() async {
    isReadingProgressLoading.value = true;
    readingProgressError.value = '';
    try {
      final response = await _repository.getStudentReadingProgress();
      overallPercent.value = response.overallPercent;
      statusMessage.value = response.statusMessage;
      storiesCompleted.value = response.storiesCompleted;
      storiesTotal.value = response.storiesTotal;
      quizScoreMean.value = response.quizScoreMean;
      streakDays.value = response.streakDays;
      chapterProgressList.assignAll(response.chapters);
    } catch (e) {
      Log.e('Failed to fetch reading progress: $e');
      readingProgressError.value =
          e is ApiException ? e.message : 'Failed to load reading progress';
    } finally {
      isReadingProgressLoading.value = false;
    }
  }

  void onExploreStories() {
    if (Get.isRegistered<MainPageController>()) {
      Get.find<MainPageController>().changePage(1); // Stories tab
      // If we pushed ReadingProgressView on top of MainPage, pop back
      if (Get.currentRoute != Routes.MAIN_PAGE) {
        Get.back();
      }
    } else {
      Get.toNamed(Routes.STORY_LIBRARY);
    }
  }
}
