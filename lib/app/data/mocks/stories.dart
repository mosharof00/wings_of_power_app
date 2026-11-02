import '../models/story_models.dart';

class StoriesMock {
  StoriesMock._();

  static bool errorOverride = false;

  static final List<StoryDetailModel> _allStories = [
    // 1. New student story (The Golden Pearl Book 1) - later chapters locked
    const StoryDetailModel(
      id: 'story-golden-pearl-1',
      title: 'The Golden Pearl Book 1',
      author: 'Audrey Cuff Ed. D.',
      synopsis:
          'The sound of the school bell rings, and all the children run out of Kramer School with glee. "I can\'t wait to tell my Grandma Pearl the big news!" I mumble.',
      category: 'Kindness',
      ageGroup: '6-9',
      coverUrl: null,
      assetPath: 'assets/book_covers/cover_the_golden_pearl_1.png',
      chapterCount: 5,
      estimatedMinutes: 10,
      isStarted: false,
      isCompleted: false,
      chapters: [
        ChapterModel(
          id: 'gp1-ch-1',
          storyId: 'story-golden-pearl-1',
          chapterNumber: 1,
          title: 'The Girl Who Believed',
          pageCount: 15,
          estimatedMinutes: 3,
          isLocked: false,
          isCompleted: false,
          assetPath: 'assets/book_covers/cover_the_golden_pearl_1.png',
        ),
        ChapterModel(
          id: 'gp1-ch-2',
          storyId: 'story-golden-pearl-1',
          chapterNumber: 2,
          title: 'The Party Plan',
          pageCount: 15,
          estimatedMinutes: 3,
          isLocked: true,
          isCompleted: false,
          assetPath: 'assets/book_covers/cover_the_golden_pearl_1.png',
        ),
        ChapterModel(
          id: 'gp1-ch-3',
          storyId: 'story-golden-pearl-1',
          chapterNumber: 3,
          title: 'A Special Invitation',
          pageCount: 15,
          estimatedMinutes: 3,
          isLocked: true,
          isCompleted: false,
          assetPath: 'assets/book_covers/cover_the_golden_pearl_1.png',
        ),
        ChapterModel(
          id: 'gp1-ch-4',
          storyId: 'story-golden-pearl-1',
          chapterNumber: 4,
          title: 'Friends Help Friends',
          pageCount: 15,
          estimatedMinutes: 3,
          isLocked: true,
          isCompleted: false,
          assetPath: 'assets/book_covers/cover_the_golden_pearl_1.png',
        ),
        ChapterModel(
          id: 'gp1-ch-5',
          storyId: 'story-golden-pearl-1',
          chapterNumber: 5,
          title: 'Let’s Eat Together',
          pageCount: 15,
          estimatedMinutes: 3,
          isLocked: true,
          isCompleted: false,
          assetPath: 'assets/book_covers/cover_the_golden_pearl_1.png',
        ),
      ],
    ),

    // 2. Returning student story (The Golden Pearl Book 2) - progress & completed chapters
    const StoryDetailModel(
      id: 'story-golden-pearl-2',
      title: 'The Golden Pearl Book 2',
      author: 'Audrey Cuff Ed. D.',
      synopsis:
          'The sound of the school bell rings, and all the children run out of Kramer School with glee. "I can\'t wait to tell my Grandma Pearl the big news!" I mumble.',
      category: 'Kindness',
      ageGroup: '6-9',
      coverUrl: null,
      assetPath: 'assets/book_covers/cover_the_golden_pearl_2.png',
      chapterCount: 5,
      estimatedMinutes: 10,
      isStarted: true,
      isCompleted: false,
      currentChapterId: 'gp2-ch-2',
      overallPercent: 0.28,
      chapters: [
        ChapterModel(
          id: 'gp2-ch-1',
          storyId: 'story-golden-pearl-2',
          chapterNumber: 1,
          title: 'The Girl Who Believed',
          pageCount: 15,
          estimatedMinutes: 3,
          isLocked: false,
          isCompleted: true,
          progressPercent: 1.0,
          assetPath: 'assets/book_covers/cover_the_golden_pearl_2.png',
        ),
        ChapterModel(
          id: 'gp2-ch-2',
          storyId: 'story-golden-pearl-2',
          chapterNumber: 2,
          title: 'The Party Plan',
          pageCount: 15,
          estimatedMinutes: 3,
          isLocked: false,
          isCompleted: false,
          progressPercent: 0.40,
          assetPath: 'assets/book_covers/cover_the_golden_pearl_2.png',
        ),
        ChapterModel(
          id: 'gp2-ch-3',
          storyId: 'story-golden-pearl-2',
          chapterNumber: 3,
          title: 'A Special Invitation',
          pageCount: 15,
          estimatedMinutes: 3,
          isLocked: false,
          isCompleted: false,
          assetPath: 'assets/book_covers/cover_the_golden_pearl_2.png',
        ),
        ChapterModel(
          id: 'gp2-ch-4',
          storyId: 'story-golden-pearl-2',
          chapterNumber: 4,
          title: 'Friends Help Friends',
          pageCount: 15,
          estimatedMinutes: 3,
          isLocked: true,
          isCompleted: false,
          assetPath: 'assets/book_covers/cover_the_golden_pearl_2.png',
        ),
        ChapterModel(
          id: 'gp2-ch-5',
          storyId: 'story-golden-pearl-2',
          chapterNumber: 5,
          title: 'Let’s Eat Together',
          pageCount: 15,
          estimatedMinutes: 3,
          isLocked: true,
          isCompleted: false,
          assetPath: 'assets/book_covers/cover_the_golden_pearl_2.png',
        ),
      ],
    ),

    // 3. Retake story (story_chapters_retake_quiz) - Quiz links next to chapter details
    const StoryDetailModel(
      id: 'story-golden-pearl-retake',
      title: 'The Golden Pearl Book 2 (Retake Quiz)',
      author: 'Audrey Cuff Ed. D.',
      synopsis:
          'Review the chapters and retake your quizzes to achieve a higher score and earn bonus kindness points!',
      category: 'Kindness',
      ageGroup: '6-9',
      coverUrl: null,
      assetPath: 'assets/book_covers/cover_the_golden_pearl_2.png',
      chapterCount: 5,
      estimatedMinutes: 10,
      isStarted: true,
      isCompleted: false,
      chapters: [
        ChapterModel(
          id: 'gpr-ch-1',
          storyId: 'story-golden-pearl-retake',
          chapterNumber: 1,
          title: 'The Girl Who Believed',
          pageCount: 15,
          estimatedMinutes: 3,
          isLocked: false,
          isCompleted: true,
          hasQuiz: true,
          quizId: 'quiz-gp-1',
          assetPath: 'assets/book_covers/cover_the_golden_pearl_2.png',
        ),
        ChapterModel(
          id: 'gpr-ch-2',
          storyId: 'story-golden-pearl-retake',
          chapterNumber: 2,
          title: 'The Party Plan',
          pageCount: 15,
          estimatedMinutes: 3,
          isLocked: false,
          isCompleted: false,
          hasQuiz: true,
          quizId: 'quiz-gp-2',
          assetPath: 'assets/book_covers/cover_the_golden_pearl_2.png',
        ),
        ChapterModel(
          id: 'gpr-ch-3',
          storyId: 'story-golden-pearl-retake',
          chapterNumber: 3,
          title: 'A Special Invitation',
          pageCount: 15,
          estimatedMinutes: 3,
          isLocked: false,
          isCompleted: false,
          assetPath: 'assets/book_covers/cover_the_golden_pearl_2.png',
        ),
        ChapterModel(
          id: 'gpr-ch-4',
          storyId: 'story-golden-pearl-retake',
          chapterNumber: 4,
          title: 'Friends Help Friends',
          pageCount: 15,
          estimatedMinutes: 3,
          isLocked: false,
          isCompleted: false,
          assetPath: 'assets/book_covers/cover_the_golden_pearl_2.png',
        ),
        ChapterModel(
          id: 'gpr-ch-5',
          storyId: 'story-golden-pearl-retake',
          chapterNumber: 5,
          title: 'Let’s Eat Together',
          pageCount: 15,
          estimatedMinutes: 3,
          isLocked: false,
          isCompleted: false,
          assetPath: 'assets/book_covers/cover_the_golden_pearl_2.png',
        ),
      ],
    ),

    // 4. City of Thieves
    const StoryDetailModel(
      id: 'story-city-of-thieves',
      title: 'City of Thieves',
      author: 'Audrey Cuff Ed. D.',
      synopsis:
          'A compelling middle-school journey about courage, empathy, and making upstander choices.',
      category: 'Cyberbullying',
      ageGroup: '10-13',
      coverUrl: null,
      assetPath: 'assets/book_covers/cover_city_of_thieves.png',
      chapterCount: 4,
      estimatedMinutes: 15,
      isStarted: false,
      isCompleted: false,
      chapters: [
        ChapterModel(
          id: 'cot-ch-1',
          storyId: 'story-city-of-thieves',
          chapterNumber: 1,
          title: 'The Digital Shadows',
          pageCount: 18,
          estimatedMinutes: 4,
          isLocked: false,
          assetPath: 'assets/book_covers/cover_city_of_thieves.png',
        ),
        ChapterModel(
          id: 'cot-ch-2',
          storyId: 'story-city-of-thieves',
          chapterNumber: 2,
          title: 'The Whispering Screen',
          pageCount: 16,
          estimatedMinutes: 4,
          isLocked: true,
          assetPath: 'assets/book_covers/cover_city_of_thieves.png',
        ),
        ChapterModel(
          id: 'cot-ch-3',
          storyId: 'story-city-of-thieves',
          chapterNumber: 3,
          title: 'Finding Allies',
          pageCount: 14,
          estimatedMinutes: 3,
          isLocked: true,
          assetPath: 'assets/book_covers/cover_city_of_thieves.png',
        ),
        ChapterModel(
          id: 'cot-ch-4',
          storyId: 'story-city-of-thieves',
          chapterNumber: 4,
          title: 'Breaking the Silence',
          pageCount: 20,
          estimatedMinutes: 4,
          isLocked: true,
          assetPath: 'assets/book_covers/cover_city_of_thieves.png',
        ),
      ],
    ),

    // 5. The Ties That Bind Us
    const StoryDetailModel(
      id: 'story-ties-that-bind-us',
      title: 'The Ties That Bind Us',
      author: 'Audrey Cuff Ed. D.',
      synopsis:
          'An inspiring story about friendship, community resilience, and standing up for your classmates.',
      category: 'Friendship',
      ageGroup: 'adults',
      coverUrl: null,
      assetPath: 'assets/book_covers/cover_the_ties_that_bind_us.png',
      chapterCount: 4,
      estimatedMinutes: 12,
      isStarted: false,
      isCompleted: false,
      chapters: [
        ChapterModel(
          id: 'ttb-ch-1',
          storyId: 'story-ties-that-bind-us',
          chapterNumber: 1,
          title: 'Crossing Paths',
          pageCount: 14,
          estimatedMinutes: 3,
          isLocked: false,
          assetPath: 'assets/book_covers/cover_the_ties_that_bind_us.png',
        ),
        ChapterModel(
          id: 'ttb-ch-2',
          storyId: 'story-ties-that-bind-us',
          chapterNumber: 2,
          title: 'A Common Thread',
          pageCount: 15,
          estimatedMinutes: 3,
          isLocked: true,
          assetPath: 'assets/book_covers/cover_the_ties_that_bind_us.png',
        ),
        ChapterModel(
          id: 'ttb-ch-3',
          storyId: 'story-ties-that-bind-us',
          chapterNumber: 3,
          title: 'Weathering the Storm',
          pageCount: 15,
          estimatedMinutes: 3,
          isLocked: true,
          assetPath: 'assets/book_covers/cover_the_ties_that_bind_us.png',
        ),
        ChapterModel(
          id: 'ttb-ch-4',
          storyId: 'story-ties-that-bind-us',
          chapterNumber: 4,
          title: 'Stronger Together',
          pageCount: 16,
          estimatedMinutes: 3,
          isLocked: true,
          assetPath: 'assets/book_covers/cover_the_ties_that_bind_us.png',
        ),
      ],
    ),
  ];

  static StorySummaryModel _toSummary(StoryDetailModel detail) {
    return StorySummaryModel(
      id: detail.id,
      title: detail.title,
      author: detail.author,
      synopsis: detail.synopsis,
      category: detail.category,
      ageGroup: detail.ageGroup,
      coverUrl: detail.coverUrl,
      assetPath: detail.assetPath,
      chapterCount: detail.chapterCount,
      estimatedMinutes: detail.estimatedMinutes,
      progressPercent: detail.overallPercent,
      isLocked: !detail.isStarted && detail.chapters.isNotEmpty && detail.chapters.first.isLocked,
    );
  }

  static StoryListResponse getStories({
    String? category,
    String? ageGroup,
    String? search,
    int page = 1,
    int perPage = 20,
  }) {
    if (errorOverride) {
      throw Exception('Failed to load stories. Please try again.');
    }

    var list = _allStories.map(_toSummary).toList();

    // In the design screenshots:
    // Kindness has The Golden Pearl Book 1 & 2
    // Courage also shows The Golden Pearl Book 1 & 2
    // Cyberbullying has City of Thieves & The Ties That Bind Us
    // Friendship has City of Thieves & The Ties That Bind Us
    // When category is provided and not 'ALL' / 'All Category':
    if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'all' &&
        category.toLowerCase() != 'all category') {
      final cat = category.toLowerCase();
      list = list.where((s) {
        if (cat == 'kindness') {
          return s.category.toLowerCase() == 'kindness' ||
              s.id.contains('golden-pearl');
        } else if (cat == 'courage') {
          return s.category.toLowerCase() == 'courage' ||
              s.id.contains('golden-pearl');
        } else if (cat == 'cyberbullying') {
          return s.category.toLowerCase() == 'cyberbullying' ||
              s.id.contains('city-of-thieves') ||
              s.id.contains('ties-that-bind');
        } else if (cat == 'friendship') {
          return s.category.toLowerCase() == 'friendship' ||
              s.id.contains('city-of-thieves') ||
              s.id.contains('ties-that-bind');
        }
        return s.category.toLowerCase() == cat;
      }).toList();
    }

    if (ageGroup != null &&
        ageGroup.isNotEmpty &&
        ageGroup.toLowerCase() != 'all' &&
        ageGroup.toLowerCase() != 'all age group') {
      final ag = ageGroup.toLowerCase().replaceAll('age ', '').trim();
      list = list.where((s) {
        final storyAg = s.ageGroup.toLowerCase();
        if (ag.contains('6') || ag == '6-9') {
          return storyAg == '6-9' || s.id.contains('golden-pearl');
        }
        if (ag.contains('10') || ag == '10-13') {
          return storyAg == '10-13' || s.id.contains('city-of-thieves');
        }
        if (ag.contains('adult') || ag.contains('14')) {
          return storyAg == 'adults' || s.id.contains('ties-that-bind');
        }
        return storyAg == ag;
      }).toList();
    }

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      list = list.where((s) {
        final matchesTitle = s.title.toLowerCase().contains(q);
        final matchesAuthor = s.author?.toLowerCase().contains(q) ?? false;
        final matchesCat = s.category.toLowerCase().contains(q);
        return matchesTitle || matchesAuthor || matchesCat;
      }).toList();
    }

    final total = list.length;
    final startIndex = (page - 1) * perPage;
    final items = startIndex < total
        ? list.skip(startIndex).take(perPage).toList()
        : <StorySummaryModel>[];

    final lastPage = (total / perPage).ceil();

    return StoryListResponse(
      items: items,
      total: total,
      page: page,
      perPage: perPage,
      lastPage: lastPage > 0 ? lastPage : 1,
    );
  }

  static StoryDetailModel getStoryDetail(String id) {
    if (errorOverride) {
      throw Exception('Failed to load story details.');
    }

    final found = _allStories.firstWhere(
      (s) => s.id == id,
      orElse: () => _allStories.first,
    );
    return found;
  }
}
