import '../models/story_models.dart';

class ChapterPagesMock {
  ChapterPagesMock._();

  static bool errorOverride = false;
  static Duration artificialDelay = const Duration(milliseconds: 350);

  static Map<String, dynamic>? lastProgress;
  static final List<Map<String, dynamic>> progressHistory = [];
  static final Set<String> completedChapters = {};

  static void reset() {
    errorOverride = false;
    lastProgress = null;
    progressHistory.clear();
    completedChapters.clear();
  }

  static const String _page1Text =
      'The sound of the school bell rings, and all the children run out of Kramer School with glee. "I can\'t wait to tell my Grandma Pearl the big news!" I mumble.\n\n'
      'I dart out of the school doors so fast that I trip over my long shoelaces and flip in the air.\n\n'
      'I then plop hard on the ground as a pile of dust covers my face.';

  static const String _page2Text =
      'Two classmates stop running and rush over with warm smiles. "Are you okay?" they ask, reaching down to help me up.\n\n'
      'Dust brushes off my knees as we laugh together. Kindness makes every bump feel smaller!';

  static const String _page3Text =
      'Grandma Pearl is waiting right at the garden gate. "I believed in you all along," she whispers with a proud hug.\n\n'
      'Today I learned that having courage means standing up even after you trip!';

  static final Map<String, ChapterDetailModel> _fixtures = {
    'gp1-ch-1': const ChapterDetailModel(
      id: 'gp1-ch-1',
      storyId: 'story-golden-pearl-1',
      chapterNumber: 1,
      title: 'The Girl Who Believed',
      audioUrl: 'https://example.com/audio/gp1-ch-1.mp3',
      durationMs: 768000,
      hasQuiz: true,
      quizId: 'quiz-gp1-ch-1',
      pages: [
        ChapterPageModel(
          number: 1,
          id: 'page-gp1-ch1-1',
          chapterId: 'gp1-ch-1',
          bodyText: _page1Text,
          assetPath: 'assets/book_covers/page_sample_1.png',
        ),
        ChapterPageModel(
          number: 2,
          id: 'page-gp1-ch1-2',
          chapterId: 'gp1-ch-1',
          bodyText: _page2Text,
          assetPath: 'assets/book_covers/page_sample_2.png',
        ),
        ChapterPageModel(
          number: 3,
          id: 'page-gp1-ch1-3',
          chapterId: 'gp1-ch-1',
          bodyText: _page3Text,
          assetPath: 'assets/book_covers/page_sample_1.png',
        ),
      ],
    ),
    'gp1-ch-2': const ChapterDetailModel(
      id: 'gp1-ch-2',
      storyId: 'story-golden-pearl-1',
      chapterNumber: 2,
      title: 'The Party Plan',
      hasQuiz: true,
      quizId: 'quiz-gp1-ch-2',
      pages: [
        ChapterPageModel(
          number: 1,
          id: 'page-gp1-ch2-1',
          chapterId: 'gp1-ch-2',
          bodyText: _page2Text,
          assetPath: 'assets/book_covers/page_sample_2.png',
        ),
        ChapterPageModel(
          number: 2,
          id: 'page-gp1-ch2-2',
          chapterId: 'gp1-ch-2',
          bodyText: _page3Text,
          assetPath: 'assets/book_covers/page_sample_1.png',
        ),
      ],
    ),
  };

  static Future<ChapterDetailModel> getChapterDetail({
    required String storyId,
    required String chapterId,
  }) async {
    if (artificialDelay.inMilliseconds > 0) {
      await Future.delayed(artificialDelay);
    }

    if (errorOverride) {
      throw Exception('Simulated network error while fetching chapter');
    }

    final key = chapterId.isNotEmpty ? chapterId : 'gp1-ch-1';
    final existing = _fixtures[key];
    if (existing != null) {
      return existing.copyWith(
        storyId: storyId.isNotEmpty ? storyId : existing.storyId,
        isCompleted: completedChapters.contains('$storyId:$chapterId'),
      );
    }

    // Dynamic fallback fixture
    return ChapterDetailModel(
      id: chapterId,
      storyId: storyId,
      chapterNumber: 1,
      title: 'The Girl Who Believed',
      audioUrl: 'https://example.com/audio/$chapterId.mp3',
      durationMs: 768000,
      hasQuiz: true,
      quizId: 'quiz-$chapterId',
      isCompleted: completedChapters.contains('$storyId:$chapterId'),
      pages: const [
        ChapterPageModel(
          number: 1,
          bodyText: _page1Text,
          assetPath: 'assets/book_covers/page_sample_1.png',
        ),
        ChapterPageModel(
          number: 2,
          bodyText: _page2Text,
          assetPath: 'assets/book_covers/page_sample_2.png',
        ),
        ChapterPageModel(
          number: 3,
          bodyText: _page3Text,
          assetPath: 'assets/book_covers/page_sample_1.png',
        ),
      ],
    );
  }

  static Future<bool> updateProgress({
    required String storyId,
    required String chapterId,
    required int pageNumber,
    required int percent,
    String mode = 'read',
  }) async {
    final entry = {
      'storyId': storyId,
      'chapterId': chapterId,
      'pageNumber': pageNumber,
      'percent': percent,
      'mode': mode,
      'timestamp': DateTime.now().toIso8601String(),
    };
    lastProgress = entry;
    progressHistory.add(entry);
    return true;
  }

  static Future<bool> completeChapter({
    required String storyId,
    required String chapterId,
  }) async {
    completedChapters.add('$storyId:$chapterId');
    return true;
  }
}
