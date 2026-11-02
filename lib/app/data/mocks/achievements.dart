import '../models/achievement_models.dart';

class AchievementsMock {
  AchievementsMock._();

  static const _kindnessChampion = BadgeModel(
    id: 'badge-kindness-champion',
    code: 'KINDNESS_CHAMPION',
    name: 'Kindness Champion',
    subtitle: 'You make the world brighter with kindness!',
    howToEarn:
        'Show kindness, support classmates, and help create a welcoming environment.',
    assetPath: 'assets/badges/badge_kindness_champion.png',
    isEarned: true,
  );

  static const _storyExplorer = BadgeModel(
    id: 'badge-story-explorer',
    code: 'STORY_EXPLORER',
    name: 'Story Explorer',
    subtitle: 'You make the world brighter with kindness!',
    howToEarn: 'Read or listen to stories and discover new ideas.',
    assetPath: 'assets/badges/badge_story_explorer.png',
    isEarned: true,
    earnedDescription:
        "You've completed a story and earned this achievement!",
  );

  static const _helpingHand = BadgeModel(
    id: 'badge-helping-hand',
    code: 'HELPING_HAND',
    name: 'Helping Hand',
    subtitle: 'You make the world brighter with kindness!',
    howToEarn:
        'Help classmates and take part in recognized helpful activities.',
    assetPath: 'assets/badges/badge_helping_hand.png',
    isEarned: true,
  );

  static const _speakUp = BadgeModel(
    id: 'badge-speak-up',
    code: 'SPEAK_UP',
    name: 'Speak Up',
    subtitle: 'You make the world brighter with kindness!',
    howToEarn:
        'Complete learning activities about asking for help, expressing feelings, and responding safely to bullying.',
    assetPath: 'assets/badges/badge_speak_up.png',
    isEarned: true,
  );

  static const _positiveLeader = BadgeModel(
    id: 'badge-positive-leader',
    code: 'POSITIVE_LEADER',
    name: 'Positive Leader',
    subtitle: 'You make the world brighter with kindness!',
    howToEarn:
        'Show positive participation, encourage inclusion, and demonstrate leadership through positive actions.',
    assetPath: 'assets/badges/badge_positive_leader.png',
    isEarned: true,
  );

  static const _gameShowReady = BadgeModel(
    id: 'badge-game-show-ready',
    code: 'GAME_SHOW_READY',
    name: 'Game Show Ready',
    subtitle: 'You make the world brighter with kindness!',
    howToEarn: 'Meet the Game Show eligibility requirements.',
    assetPath: 'assets/badges/badge_game_show_ready.png',
    isEarned: true,
  );

  /// 6 of 6 earned — matches `badges_list_with_earned.png`
  static BadgesResponseModel get allEarnedBadges => const BadgesResponseModel(
        badges: [
          _kindnessChampion,
          _storyExplorer,
          _helpingHand,
          _speakUp,
          _positiveLeader,
          _gameShowReady,
        ],
        earnedCount: 6,
        totalCount: 6,
        points: 248,
      );

  /// All 6 locked — matches `badges_list_detail_view.png`
  static BadgesResponseModel get allLockedBadges => BadgesResponseModel(
        badges: [
          _kindnessChampion.copyWith(isEarned: false),
          _storyExplorer.copyWith(isEarned: false),
          _helpingHand.copyWith(isEarned: false),
          _speakUp.copyWith(isEarned: false),
          _positiveLeader.copyWith(isEarned: false),
          _gameShowReady.copyWith(isEarned: false),
        ],
        earnedCount: 0,
        totalCount: 6,
        points: 248,
      );

  /// Partial unlock (2 earned, 4 locked) — matches `badges_list_empty.png`
  static BadgesResponseModel get partialBadges => BadgesResponseModel(
        badges: [
          _kindnessChampion,
          _storyExplorer,
          _helpingHand.copyWith(isEarned: false),
          _speakUp.copyWith(isEarned: false),
          _positiveLeader.copyWith(isEarned: false),
          _gameShowReady.copyWith(isEarned: false),
        ],
        earnedCount: 2,
        totalCount: 6,
        points: 248,
      );

  /// 0 of 6 earned with partial art — matches `profile_badges_tab.png`
  static BadgesResponseModel get profileBadgesTab => BadgesResponseModel(
        badges: [
          _kindnessChampion,
          _storyExplorer,
          _helpingHand,
          _speakUp,
          _positiveLeader.copyWith(isEarned: false),
          _gameShowReady.copyWith(isEarned: false),
        ],
        earnedCount: 0,
        totalCount: 6,
        points: 248,
      );

  static BadgeModel getBadgeById(String id) {
    final list = allEarnedBadges.badges;
    return list.firstWhere(
      (b) => b.id == id || b.code.toLowerCase() == id.toLowerCase(),
      orElse: () => _kindnessChampion,
    );
  }

  /// Points history ledger — matches `profile_positive_points.png`
  static PositivePointsModel get positivePoints => const PositivePointsModel(
        totalPoints: 245,
        todayPoints: 30,
        items: [
          PointLedgerItemModel(
            id: 'pt-1',
            category: 'Completing Story',
            reason: 'Finished City of Thieves',
            dateLabel: 'Today',
            amount: 30,
          ),
          PointLedgerItemModel(
            id: 'pt-2',
            category: 'Answering Questions',
            reason: '3 correct answers',
            dateLabel: 'Today',
            amount: 30,
          ),
          PointLedgerItemModel(
            id: 'pt-3',
            category: 'Wings of Power',
            reason: 'Completing challenges',
            dateLabel: 'Today',
            amount: 30,
          ),
          PointLedgerItemModel(
            id: 'pt-4',
            category: 'Positive Participation',
            reason: 'Great class participation',
            dateLabel: 'Today',
            amount: 30,
          ),
          PointLedgerItemModel(
            id: 'pt-5',
            category: 'Completing Story',
            reason: 'Finished City of Thieves',
            dateLabel: 'Today',
            amount: 30,
          ),
          PointLedgerItemModel(
            id: 'pt-6',
            category: 'Answering Questions',
            reason: '3 correct answers',
            dateLabel: 'Today',
            amount: 30,
          ),
        ],
      );

  /// Empty points ledger
  static PositivePointsModel get emptyPoints => const PositivePointsModel(
        totalPoints: 0,
        todayPoints: 0,
        items: [],
      );

  /// Kindness Leaderboard — matches `profile_leaderboard.png`
  /// Decision 5: Student avatar, student name, kindness points (no character hero figures).
  static LeaderboardModel get leaderboard => const LeaderboardModel(
        podium: [
          LeaderboardItemModel(
            id: 'student-faith',
            rank: 2,
            nickname: 'Faith',
            avatarUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=150',
            kindnessPoints: 3249,
          ),
          LeaderboardItemModel(
            id: 'student-mili-top',
            rank: 1,
            nickname: 'Mili',
            avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
            kindnessPoints: 3486,
          ),
          LeaderboardItemModel(
            id: 'student-frank',
            rank: 3,
            nickname: 'Frank',
            avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150',
            kindnessPoints: 2950,
          ),
        ],
        rankedList: [
          LeaderboardItemModel(
            id: 'student-current-mili',
            rank: 4,
            nickname: 'Mili',
            avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
            kindnessPoints: 2450,
            isCurrentStudent: true,
          ),
          LeaderboardItemModel(
            id: 'student-emma',
            rank: 5,
            nickname: 'Emma',
            avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
            kindnessPoints: 1980,
          ),
          LeaderboardItemModel(
            id: 'student-ethan',
            rank: 6,
            nickname: 'Ethan',
            avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
            kindnessPoints: 1880,
          ),
          LeaderboardItemModel(
            id: 'student-lily',
            rank: 7,
            nickname: 'Lily',
            avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
            kindnessPoints: 1420,
          ),
        ],
      );

  /// Reading progress — matches `profile_reading_progress.png`
  static ReadingProgressModel get readingProgress => const ReadingProgressModel(
        overallPercent: 60,
        statusMessage: 'Keep reading!',
        storiesCompleted: 1,
        storiesTotal: 8,
        quizScoreMean: 52,
        streakDays: 5,
        chapters: [
          ChapterProgressItemModel(
            id: 'ch-1',
            bookTitle: 'THE GOLDEN PEARL',
            bookVolume: 'Book 2',
            storyTitle: "Let's Party!",
            chapterTitle: 'Chapter 1',
            chapterName: 'The Girl Who Believed',
            pageCount: 15,
            readingMinutes: 3,
            progressPercent: 100,
            coverAsset: 'assets/book_covers/cover_golden_pearl.png',
          ),
          ChapterProgressItemModel(
            id: 'ch-2',
            bookTitle: 'THE GOLDEN PEARL',
            bookVolume: 'Book 2',
            storyTitle: "Let's Party!",
            chapterTitle: 'Chapter 2',
            chapterName: 'The Party Plan',
            pageCount: 15,
            readingMinutes: 3,
            progressPercent: 30,
            coverAsset: 'assets/book_covers/cover_golden_pearl.png',
          ),
        ],
      );
}
