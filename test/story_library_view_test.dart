import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/theme/app_theme.dart';
import 'package:wings_of_power_app/app/data/models/story_models.dart';
import 'package:wings_of_power_app/app/data/repositories/story_repository.dart';
import 'package:wings_of_power_app/app/modules/stories/controllers/stories_controller.dart';
import 'package:wings_of_power_app/app/modules/stories/views/story_library_view.dart';

class _FakeRepo implements IStoryRepository {
  @override
  Future<List<StoryThemeModel>> getThemes() async => const [
        StoryThemeModel(id: 'theme_kindness', name: 'Kindness', slug: 'kindness'),
        StoryThemeModel(id: 'theme_courage', name: 'Courage', slug: 'courage'),
      ];

  @override
  Future<StoryListResponse> getStories({
    String? themeId,
    String? category,
    String? ageGroup,
    String? search,
    int page = 1,
    int perPage = 50,
  }) async {
    final all = const [
      StorySummaryModel(
        id: 'a',
        title: 'Faith and the Power of Melody',
        category: 'kindness',
        themeId: 'theme_kindness',
        ageGroup: 'AGE_6_9',
      ),
      StorySummaryModel(
        id: 'b',
        title: 'Brave Steps',
        category: 'courage',
        themeId: 'theme_courage',
        ageGroup: 'AGE_10_13',
      ),
    ];
    var items = all;
    if (themeId != null) {
      items = all.where((s) => s.themeId == themeId).toList();
    }
    return StoryListResponse(
      items: items,
      total: items.length,
      page: 1,
      perPage: perPage,
      lastPage: 1,
    );
  }

  @override
  Future<StoryDetailModel> getStoryDetail(String id) =>
      throw UnimplementedError();

  @override
  Future<ChapterDetailModel> getChapterDetail({
    required String storyId,
    required String chapterId,
  }) =>
      throw UnimplementedError();

  @override
  Future<bool> updateReadingProgress({
    required String storyId,
    required String chapterId,
    required int pageNumber,
    required int percent,
    String mode = 'read',
  }) =>
      throw UnimplementedError();

  @override
  Future<bool> markPageRead({
    required String storyId,
    required String chapterId,
    required int pageNumber,
    required String mode,
    int? dwellSeconds,
    int? listenPercent,
  }) => throw UnimplementedError();

  @override
  Future<bool> completeChapter({
    required String storyId,
    required String chapterId,
  }) =>
      throw UnimplementedError();
}

void main() {
  tearDown(Get.reset);

  testWidgets('StoryLibraryView shows dynamic theme sections', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Get.put(StoriesController(_FakeRepo()));

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => GetMaterialApp(
          theme: AppTheme.light(),
          home: const StoryLibraryView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Story Library'), findsOneWidget);
    expect(find.text('Search stories...'), findsOneWidget);
    expect(find.text('All Category'), findsOneWidget);
    expect(find.text('All Age Group'), findsOneWidget);
    expect(find.text('Kindness'), findsOneWidget);
    expect(find.text('Courage'), findsOneWidget);
    expect(find.text('Faith and the Power of Melody'), findsOneWidget);
    expect(find.text('Brave Steps'), findsOneWidget);
    expect(find.text('See all'), findsNWidgets(2));
  });
}
