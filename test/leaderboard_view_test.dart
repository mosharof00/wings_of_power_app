import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/mocks/achievements.dart';
import 'package:wings_of_power_app/app/data/models/achievement_models.dart';
import 'package:wings_of_power_app/app/data/repositories/achievement_repository.dart';
import 'package:wings_of_power_app/app/modules/achievements/controllers/achievements_controller.dart';
import 'package:wings_of_power_app/app/modules/achievements/views/leaderboard_view.dart';

void main() {
  testWidgets('keeps tied students distinct and scrolls to the ranked list', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() => Get.reset());

    final controller = Get.put(
      AchievementsController(_LeaderboardRepository()),
    );
    await Future<void>.value();
    controller.podium.assignAll(const [
      LeaderboardItemModel(
        id: 'a',
        rank: 1,
        nickname: 'Avery',
        kindnessPoints: 3486,
      ),
      LeaderboardItemModel(
        id: 'b',
        rank: 1,
        nickname: 'Blake',
        kindnessPoints: 3486,
      ),
      LeaderboardItemModel(
        id: 'c',
        rank: 3,
        nickname: 'Casey',
        kindnessPoints: 2950,
      ),
    ]);
    controller.rankedList.assignAll(
      List.generate(8, (index) {
        final rank = index + 4;
        return LeaderboardItemModel(
          id: 'student-$rank',
          rank: rank,
          nickname: 'Student $rank',
          kindnessPoints: 2450 - index * 100,
        );
      }),
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => const GetMaterialApp(home: LeaderboardView()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Avery'), findsOneWidget);
    expect(find.text('Blake'), findsOneWidget);
    expect(find.text('Casey'), findsOneWidget);
    expect(find.text('3,486'), findsNWidgets(2));
    expect(find.text('#4'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Student 11'), 230);
    expect(tester.takeException(), isNull);

    controller.podium.removeRange(1, 3);
    controller.rankedList.clear();
    await tester.pumpAndSettle();
    expect(find.text('Avery'), findsOneWidget);
    expect(find.text('Blake'), findsNothing);
    expect(find.text('3,486'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _LeaderboardRepository implements IAchievementRepository {
  @override
  Future<BadgesResponseModel> getBadges({String? fixtureState}) async =>
      AchievementsMock.allEarnedBadges;

  @override
  Future<BadgeModel> getBadgeDetail(String id) async =>
      AchievementsMock.getBadgeById(id);

  @override
  Future<PositivePointsModel> getStudentPoints({
    int page = 1,
    int perPage = 20,
  }) async => AchievementsMock.emptyPoints;

  @override
  Future<LeaderboardModel> getStudentLeaderboard({
    String scope = 'class',
  }) async => AchievementsMock.leaderboard;

  @override
  Future<ReadingProgressModel> getStudentReadingProgress() async =>
      AchievementsMock.readingProgress;
}
