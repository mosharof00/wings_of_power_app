import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/models/story_models.dart';
import 'package:wings_of_power_app/app/data/repositories/story_repository.dart';
import 'package:wings_of_power_app/app/modules/stories/controllers/stories_controller.dart';

class _FakeStoryRepository implements IStoryRepository {
  _FakeStoryRepository({
    this.themes = const [],
    this.stories = const [],
    this.throwOnThemes = false,
  });

  List<StoryThemeModel> themes;
  List<StorySummaryModel> stories;
  bool throwOnThemes;

  String? lastThemeId;
  String? lastCategory;
  String? lastAgeGroup;
  String? lastSearch;

  @override
  Future<List<StoryThemeModel>> getThemes() async {
    if (throwOnThemes) throw Exception('themes failed');
    return themes;
  }

  @override
  Future<StoryListResponse> getStories({
    String? themeId,
    String? category,
    String? ageGroup,
    String? search,
    int page = 1,
    int perPage = 50,
  }) async {
    lastThemeId = themeId;
    lastCategory = category;
    lastAgeGroup = ageGroup;
    lastSearch = search;

    var items = List<StorySummaryModel>.from(stories);
    if (themeId != null && themeId.isNotEmpty) {
      items = items.where((s) => s.themeId == themeId).toList();
    } else if (category != null && category.isNotEmpty) {
      items = items
          .where((s) => s.category.toLowerCase() == category.toLowerCase())
          .toList();
    }
    if (ageGroup != null && ageGroup.isNotEmpty) {
      items = items.where((s) {
        final ag = s.ageGroup.toUpperCase();
        if (ageGroup == 'AGE_6_9') {
          return ag == 'AGE_6_9' || ag == '6-9';
        }
        if (ageGroup == 'AGE_10_13') {
          return ag == 'AGE_10_13' || ag == '10-13';
        }
        if (ageGroup == 'ADULTS') {
          return ag == 'ADULTS';
        }
        return true;
      }).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.toLowerCase();
      items = items.where((s) => s.title.toLowerCase().contains(q)).toList();
    }

    return StoryListResponse(
      items: items,
      total: items.length,
      page: page,
      perPage: perPage,
      lastPage: 1,
    );
  }

  @override
  Future<StoryDetailModel> getStoryDetail(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<ChapterDetailModel> getChapterDetail({
    required String storyId,
    required String chapterId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> updateReadingProgress({
    required String storyId,
    required String chapterId,
    required int pageNumber,
    required int percent,
    String mode = 'read',
  }) async {
    throw UnimplementedError();
  }

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
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  const kindness = StoryThemeModel(
    id: 'theme_kindness',
    name: 'Kindness',
    slug: 'kindness',
  );
  const courage = StoryThemeModel(
    id: 'theme_courage',
    name: 'Courage',
    slug: 'courage',
  );

  const storyA = StorySummaryModel(
    id: 'a',
    title: 'Faith and the Power of Melody',
    category: 'kindness',
    themeId: 'theme_kindness',
    themeName: 'Kindness',
    ageGroup: 'AGE_6_9',
  );
  const storyB = StorySummaryModel(
    id: 'b',
    title: 'The Lion and the Mouse',
    category: 'kindness',
    themeId: 'theme_kindness',
    themeName: 'Kindness',
    ageGroup: 'AGE_10_13',
  );
  const storyC = StorySummaryModel(
    id: 'c',
    title: 'Brave Steps',
    category: 'courage',
    themeId: 'theme_courage',
    themeName: 'Courage',
    ageGroup: 'ADULTS',
  );

  tearDown(Get.reset);

  test('loadLibrary fetches themes and stories', () async {
    final repo = _FakeStoryRepository(
      themes: const [kindness, courage],
      stories: const [storyA, storyB, storyC],
    );
    final c = StoriesController(repo);
    addTearDown(c.dispose);

    await c.loadLibrary();

    expect(c.isLoading.value, isFalse);
    expect(c.errorMessage.value, isEmpty);
    expect(c.themes.length, 2);
    expect(c.stories.length, 3);
    expect(c.categoryFilterOptions, [
      'All Category',
      'Kindness',
      'Courage',
    ]);
  });

  test('themeSections groups by themeId without duplicating rows', () async {
    final repo = _FakeStoryRepository(
      themes: const [kindness, courage],
      stories: const [storyA, storyB, storyC],
    );
    final c = StoriesController(repo);
    addTearDown(c.dispose);
    await c.loadLibrary();

    final sections = c.themeSections;
    expect(sections.length, 2);
    expect(sections[0].theme.name, 'Kindness');
    expect(sections[0].stories.map((s) => s.id), ['a', 'b']);
    expect(sections[1].theme.name, 'Courage');
    expect(sections[1].stories.map((s) => s.id), ['c']);
  });

  test('setCategoryLabel passes themeId to repository', () async {
    final repo = _FakeStoryRepository(
      themes: const [kindness, courage],
      stories: const [storyA, storyB, storyC],
    );
    final c = StoriesController(repo);
    addTearDown(c.dispose);
    await c.loadLibrary();

    c.setCategoryLabel('Courage');
    await Future<void>.delayed(Duration.zero);
    await c.fetchStories();

    expect(c.selectedThemeId.value, 'theme_courage');
    expect(repo.lastThemeId, 'theme_courage');
    expect(c.stories.map((s) => s.id), ['c']);
  });

  test('setAgeGroupLabel maps UI labels to API enums', () async {
    final repo = _FakeStoryRepository(
      themes: const [kindness],
      stories: const [storyA, storyB, storyC],
    );
    final c = StoriesController(repo);
    addTearDown(c.dispose);
    await c.loadLibrary();

    c.setAgeGroupLabel('Age 6 to 9');
    await c.fetchStories();
    expect(repo.lastAgeGroup, 'AGE_6_9');
    expect(c.stories.map((s) => s.id), ['a']);

    c.setAgeGroupLabel('Adults');
    await c.fetchStories();
    expect(repo.lastAgeGroup, 'ADULTS');
    expect(c.stories.map((s) => s.id), ['c']);
  });

  test('storiesForAgeBand filters client-side bands', () async {
    final repo = _FakeStoryRepository(
      themes: const [kindness, courage],
      stories: const [storyA, storyB, storyC],
    );
    final c = StoriesController(repo);
    addTearDown(c.dispose);
    await c.loadLibrary();

    expect(c.storiesForAgeBand('AGE_6_9').map((s) => s.id), ['a']);
    expect(c.storiesForAgeBand('AGE_10_13').map((s) => s.id), ['b']);
    expect(c.storiesForAgeBand('ADULTS').map((s) => s.id), ['c']);
  });

  test('loadLibrary surfaces theme fetch errors', () async {
    final repo = _FakeStoryRepository(throwOnThemes: true);
    final c = StoriesController(repo);
    addTearDown(c.dispose);

    await c.loadLibrary();

    expect(c.isLoading.value, isFalse);
    expect(c.errorMessage.value, 'themes failed');
  });

  test('resolves themeId from category name args', () async {
    final repo = _FakeStoryRepository(
      themes: const [kindness, courage],
      stories: const [storyA, storyC],
    );
    final c = StoriesController(repo);
    addTearDown(c.dispose);
    c.selectedCategoryLabel.value = 'Courage';

    await c.loadLibrary();

    expect(c.selectedThemeId.value, 'theme_courage');
    expect(c.selectedCategoryLabel.value, 'Courage');
    expect(repo.lastThemeId, 'theme_courage');
  });
}
