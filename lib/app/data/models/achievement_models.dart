class BadgeModel {
  final String id;
  final String code;
  final String name;
  final String subtitle;
  final String howToEarn;
  final String assetPath;
  final bool isEarned;
  final String? earnedDescription;
  final DateTime? unlockedAt;

  const BadgeModel({
    required this.id,
    required this.code,
    required this.name,
    required this.subtitle,
    required this.howToEarn,
    required this.assetPath,
    required this.isEarned,
    this.earnedDescription,
    this.unlockedAt,
  });

  BadgeModel copyWith({
    String? id,
    String? code,
    String? name,
    String? subtitle,
    String? howToEarn,
    String? assetPath,
    bool? isEarned,
    String? earnedDescription,
    DateTime? unlockedAt,
  }) {
    return BadgeModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      howToEarn: howToEarn ?? this.howToEarn,
      assetPath: assetPath ?? this.assetPath,
      isEarned: isEarned ?? this.isEarned,
      earnedDescription: earnedDescription ?? this.earnedDescription,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: (json['id'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? 'You make the world brighter with kindness!').toString(),
      howToEarn: (json['howToEarn'] ?? json['how_to_earn'] ?? json['criteriaDescription'] ?? '').toString(),
      assetPath: (json['assetPath'] ?? json['asset_path'] ?? 'assets/badges/badge_locked.png').toString(),
      isEarned: json['isEarned'] == true || json['is_earned'] == true || json['earned'] == true,
      earnedDescription: json['earnedDescription']?.toString() ?? json['earned_description']?.toString(),
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.tryParse(json['unlockedAt'].toString())
          : (json['unlocked_at'] != null ? DateTime.tryParse(json['unlocked_at'].toString()) : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'subtitle': subtitle,
        'howToEarn': howToEarn,
        'assetPath': assetPath,
        'isEarned': isEarned,
        'earnedDescription': earnedDescription,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };
}

class BadgesResponseModel {
  final List<BadgeModel> badges;
  final int earnedCount;
  final int totalCount;
  final int points;

  const BadgesResponseModel({
    required this.badges,
    required this.earnedCount,
    required this.totalCount,
    required this.points,
  });

  factory BadgesResponseModel.fromJson(Map<String, dynamic> json) {
    final list = (json['badges'] as List? ?? json['items'] as List? ?? [])
        .map((e) => BadgeModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final earned = json['earnedCount'] as int? ??
        json['earned_count'] as int? ??
        list.where((b) => b.isEarned).length;
    final total = json['totalCount'] as int? ?? json['total_count'] as int? ?? list.length;
    final pts = json['points'] as int? ?? json['totalPoints'] as int? ?? 248;

    return BadgesResponseModel(
      badges: list,
      earnedCount: earned,
      totalCount: total,
      points: pts,
    );
  }

  Map<String, dynamic> toJson() => {
        'badges': badges.map((b) => b.toJson()).toList(),
        'earnedCount': earnedCount,
        'totalCount': totalCount,
        'points': points,
      };
}

class PointLedgerItemModel {
  final String id;
  final String category;
  final String reason;
  final String dateLabel;
  final int amount;
  final bool isPositive;
  final DateTime? createdAt;

  const PointLedgerItemModel({
    required this.id,
    required this.category,
    required this.reason,
    required this.dateLabel,
    required this.amount,
    this.isPositive = true,
    this.createdAt,
  });

  factory PointLedgerItemModel.fromJson(Map<String, dynamic> json) {
    final amt = json['amount'] as int? ?? json['points'] as int? ?? 0;
    return PointLedgerItemModel(
      id: (json['id'] ?? '').toString(),
      category: (json['category'] ?? 'Positive Points').toString(),
      reason: (json['reason'] ?? json['detail'] ?? '').toString(),
      dateLabel: (json['dateLabel'] ?? json['date_label'] ?? json['at'] ?? 'Today').toString(),
      amount: amt.abs(),
      isPositive: amt >= 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'reason': reason,
        'dateLabel': dateLabel,
        'amount': amount,
        'isPositive': isPositive,
        'createdAt': createdAt?.toIso8601String(),
      };
}

class PositivePointsModel {
  final int totalPoints;
  final int todayPoints;
  final List<PointLedgerItemModel> items;

  const PositivePointsModel({
    required this.totalPoints,
    required this.todayPoints,
    required this.items,
  });

  factory PositivePointsModel.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List? ??
            json['ledger'] as List? ??
            json['history'] as List? ??
            [])
        .map((e) => PointLedgerItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return PositivePointsModel(
      totalPoints: json['totalPoints'] as int? ?? json['total_points'] as int? ?? 245,
      todayPoints: json['todayPoints'] as int? ?? json['today_points'] as int? ?? 30,
      items: rawItems,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalPoints': totalPoints,
        'todayPoints': todayPoints,
        'items': items.map((i) => i.toJson()).toList(),
      };
}

class LeaderboardItemModel {
  final String id;
  final int rank;
  final String nickname;
  final String? avatarUrl;
  final int kindnessPoints;
  final bool isCurrentStudent;

  const LeaderboardItemModel({
    required this.id,
    required this.rank,
    required this.nickname,
    this.avatarUrl,
    required this.kindnessPoints,
    this.isCurrentStudent = false,
  });

  factory LeaderboardItemModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardItemModel(
      id: (json['id'] ?? json['userId'] ?? '').toString(),
      rank: json['rank'] as int? ?? 0,
      nickname: (json['nickname'] ?? json['name'] ?? json['studentName'] ?? '').toString(),
      avatarUrl: json['avatarUrl']?.toString() ?? json['avatar_url']?.toString(),
      kindnessPoints: json['kindnessPoints'] as int? ??
          json['kindness_points'] as int? ??
          json['points'] as int? ??
          0,
      isCurrentStudent: json['isCurrentStudent'] == true || json['is_current_student'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'rank': rank,
        'nickname': nickname,
        'avatarUrl': avatarUrl,
        'kindnessPoints': kindnessPoints,
        'isCurrentStudent': isCurrentStudent,
      };
}

class LeaderboardModel {
  final List<LeaderboardItemModel> podium;
  final List<LeaderboardItemModel> rankedList;
  final LeaderboardItemModel? currentStudent;
  final String scope;

  const LeaderboardModel({
    required this.podium,
    required this.rankedList,
    this.currentStudent,
    this.scope = 'class',
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    final rawList = (json['items'] as List? ??
            json['students'] as List? ??
            json['leaderboard'] as List? ??
            [])
        .map((e) => LeaderboardItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    rawList.sort((a, b) => a.rank.compareTo(b.rank));

    final podiumItems = rawList.take(3).toList();
    final remaining = rawList.skip(3).toList();
    final current = rawList.firstWhere(
      (item) => item.isCurrentStudent,
      orElse: () => remaining.isNotEmpty ? remaining.first : podiumItems.first,
    );

    return LeaderboardModel(
      podium: podiumItems,
      rankedList: remaining,
      currentStudent: current,
      scope: (json['scope'] ?? 'class').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'podium': podium.map((p) => p.toJson()).toList(),
        'rankedList': rankedList.map((r) => r.toJson()).toList(),
        'currentStudent': currentStudent?.toJson(),
        'scope': scope,
      };
}

class ChapterProgressItemModel {
  final String id;
  final String bookTitle;
  final String bookVolume;
  final String storyTitle;
  final String chapterTitle;
  final String chapterName;
  final int pageCount;
  final int readingMinutes;
  final int progressPercent;
  final String? coverAsset;

  const ChapterProgressItemModel({
    required this.id,
    required this.bookTitle,
    required this.bookVolume,
    required this.storyTitle,
    required this.chapterTitle,
    required this.chapterName,
    required this.pageCount,
    required this.readingMinutes,
    required this.progressPercent,
    this.coverAsset,
  });

  factory ChapterProgressItemModel.fromJson(Map<String, dynamic> json) {
    return ChapterProgressItemModel(
      id: (json['id'] ?? '').toString(),
      bookTitle: (json['bookTitle'] ?? json['book_title'] ?? 'THE GOLDEN PEARL').toString(),
      bookVolume: (json['bookVolume'] ?? json['book_volume'] ?? 'Book 2').toString(),
      storyTitle: (json['storyTitle'] ?? json['story_title'] ?? "Let's Party!").toString(),
      chapterTitle: (json['chapterTitle'] ?? json['chapter_title'] ?? 'Chapter 1').toString(),
      chapterName: (json['chapterName'] ?? json['chapter_name'] ?? '').toString(),
      pageCount: json['pageCount'] as int? ?? json['page_count'] as int? ?? 15,
      readingMinutes: json['readingMinutes'] as int? ?? json['reading_minutes'] as int? ?? 3,
      progressPercent: json['progressPercent'] as int? ?? json['progress_percent'] as int? ?? 0,
      coverAsset: json['coverAsset']?.toString() ?? json['cover_asset']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookTitle': bookTitle,
        'bookVolume': bookVolume,
        'storyTitle': storyTitle,
        'chapterTitle': chapterTitle,
        'chapterName': chapterName,
        'pageCount': pageCount,
        'readingMinutes': readingMinutes,
        'progressPercent': progressPercent,
        'coverAsset': coverAsset,
      };
}

class ReadingProgressModel {
  final int overallPercent;
  final String statusMessage;
  final int storiesCompleted;
  final int storiesTotal;
  final int quizScoreMean;
  final int streakDays;
  final List<ChapterProgressItemModel> chapters;

  const ReadingProgressModel({
    required this.overallPercent,
    required this.statusMessage,
    required this.storiesCompleted,
    required this.storiesTotal,
    required this.quizScoreMean,
    required this.streakDays,
    required this.chapters,
  });

  factory ReadingProgressModel.fromJson(Map<String, dynamic> json) {
    final rawChapters = (json['chapters'] as List? ??
            json['progress'] as List? ??
            [])
        .map((e) => ChapterProgressItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return ReadingProgressModel(
      overallPercent: json['overallPercent'] as int? ?? json['overall_percent'] as int? ?? 60,
      statusMessage: (json['statusMessage'] ?? json['status_message'] ?? 'Keep reading!').toString(),
      storiesCompleted: json['storiesCompleted'] as int? ?? json['stories_completed'] as int? ?? 1,
      storiesTotal: json['storiesTotal'] as int? ?? json['stories_total'] as int? ?? 8,
      quizScoreMean: json['quizScoreMean'] as int? ?? json['quiz_score_mean'] as int? ?? 52,
      streakDays: json['streakDays'] as int? ?? json['streak_days'] as int? ?? 5,
      chapters: rawChapters,
    );
  }

  Map<String, dynamic> toJson() => {
        'overallPercent': overallPercent,
        'statusMessage': statusMessage,
        'storiesCompleted': storiesCompleted,
        'storiesTotal': storiesTotal,
        'quizScoreMean': quizScoreMean,
        'streakDays': streakDays,
        'chapters': chapters.map((c) => c.toJson()).toList(),
      };
}
