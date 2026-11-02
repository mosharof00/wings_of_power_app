import '../models/home_models.dart';

enum HomeMockState {
  newStudent,
  inProgress,
  quiz,
}

/// Fixture for student home until T-BE-011.
class HomeMock {
  HomeMock._();

  static HomeMockState stateOverride = HomeMockState.newStudent;
  static bool errorOverride = false;

  static List<HomeCategoryModel> get defaultCategories => _defaultCategories;
  static List<HomeStoryModel> get defaultPopularStories => _defaultPopularStories;

  static final List<HomeCategoryModel> _defaultCategories = [
    const HomeCategoryModel(
      id: 'cat-kindness',
      title: 'Kindness',
      storyCount: 5,
      assetPath: 'assets/images/category_kindness.png',
    ),
    const HomeCategoryModel(
      id: 'cat-courage',
      title: 'Courage',
      storyCount: 3,
      assetPath: 'assets/images/category_courage.png',
    ),
    const HomeCategoryModel(
      id: 'cat-cyberbullying',
      title: 'Cyberbullying',
      storyCount: 4,
      assetPath: 'assets/images/category_kindness.png',
    ),
    const HomeCategoryModel(
      id: 'cat-friendship',
      title: 'Friendship',
      storyCount: 6,
      assetPath: 'assets/images/category_courage.png',
    ),
  ];

  static final List<HomeStoryModel> _defaultPopularStories = [
    const HomeStoryModel(
      id: 'story-golden-pearl-1',
      title: 'The Golden Pearl Book 1',
      subtitle: 'Audrey Cuff Ed.D.',
      assetPath: 'assets/book_covers/cover_the_golden_pearl_1.png',
    ),
    const HomeStoryModel(
      id: 'story-golden-pearl-2',
      title: 'The Golden Pearl Book 2',
      subtitle: 'Audrey Cuff Ed.D.',
      assetPath: 'assets/book_covers/cover_the_golden_pearl_2.png',
    ),
    const HomeStoryModel(
      id: 'story-city-of-thieves',
      title: 'City of Theives',
      subtitle: 'Audrey Cuff Ed.D.',
      assetPath: 'assets/book_covers/cover_city_of_thieves.png',
    ),
    const HomeStoryModel(
      id: 'story-ties-that-bind-us',
      title: 'The Ties That Bind Us',
      subtitle: 'Audrey Cuff Ed.D.',
      assetPath: 'assets/book_covers/cover_the_ties_that_bind_us.png',
    ),
  ];

  static HomeDataModel getHome() {
    if (errorOverride) {
      throw Exception('Failed to load home data. Please try again.');
    }

    switch (stateOverride) {
      case HomeMockState.inProgress:
        return HomeDataModel(
          greeting: 'Hey Sarah!',
          subtitle: 'Ready to learn today?',
          points: 50,
          banner: const HomeBannerModel(
            type: HomeBannerType.continueReading,
            title: 'Keep going!',
            subtitle: "You're doing great!",
            storyTitle: 'The Golden Pearl',
            progressText: '3/4',
            progressPercent: 0.75,
            buttonText: 'Continue',
            assetPath: 'assets/characters/home_banner_continue.png',
          ),
          categories: _defaultCategories,
          popularStories: _defaultPopularStories,
          isEligibleForGame: true,
        );

      case HomeMockState.quiz:
        return HomeDataModel(
          greeting: 'Hey Sarah!',
          subtitle: 'Ready to learn today?',
          points: 50,
          banner: const HomeBannerModel(
            type: HomeBannerType.quiz,
            title: 'Finish your quiz to unlock next chapter!',
            buttonText: 'Take the Quiz',
            assetPath: 'assets/characters/home_banner_quiz.png',
          ),
          categories: _defaultCategories,
          popularStories: _defaultPopularStories,
          isEligibleForGame: true,
        );

      case HomeMockState.newStudent:
        return HomeDataModel(
          greeting: 'Hey Sarah!',
          subtitle: 'Ready to learn today?',
          points: 0,
          banner: const HomeBannerModel(
            type: HomeBannerType.startReading,
            title: 'Start your first story!',
            subtitle: 'Unlock all power wings!',
            buttonText: 'Start Reading',
            assetPath: 'assets/characters/home_banner_reader.png',
          ),
          categories: _defaultCategories,
          popularStories: _defaultPopularStories,
          isEligibleForGame: true,
        );
    }
  }
}
