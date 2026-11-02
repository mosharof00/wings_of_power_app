enum HomeBannerType {
  startReading,
  continueReading,
  quiz,
}

class HomeBannerModel {
  const HomeBannerModel({
    required this.type,
    required this.title,
    this.subtitle,
    required this.buttonText,
    this.storyId,
    this.storyTitle,
    this.progressText,
    this.progressPercent,
    this.chapterId,
    this.assetPath,
  });

  final HomeBannerType type;
  final String title;
  final String? subtitle;
  final String buttonText;
  final String? storyId;
  final String? storyTitle;
  final String? progressText;
  final double? progressPercent;
  final String? chapterId;
  final String? assetPath;

  factory HomeBannerModel.fromJson(Map<String, dynamic> json) {
    HomeBannerType parseType(String? raw) {
      switch (raw) {
        case 'continueReading':
        case 'CONTINUE':
        case 'in_progress':
          return HomeBannerType.continueReading;
        case 'quiz':
        case 'QUIZ':
        case 'take_quiz':
          return HomeBannerType.quiz;
        default:
          return HomeBannerType.startReading;
      }
    }

    return HomeBannerModel(
      type: parseType(json['type'] as String?),
      title: json['title'] as String? ?? 'Start your first story!',
      subtitle: json['subtitle'] as String?,
      buttonText: json['buttonText'] as String? ?? 'Start Reading',
      storyId: json['storyId'] as String?,
      storyTitle: json['storyTitle'] as String?,
      progressText: json['progressText'] as String?,
      progressPercent: (json['progressPercent'] as num?)?.toDouble(),
      chapterId: json['chapterId'] as String?,
      assetPath: json['assetPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'title': title,
        'subtitle': subtitle,
        'buttonText': buttonText,
        'storyId': storyId,
        'storyTitle': storyTitle,
        'progressText': progressText,
        'progressPercent': progressPercent,
        'chapterId': chapterId,
        'assetPath': assetPath,
      };
}

class HomeCategoryModel {
  const HomeCategoryModel({
    required this.id,
    required this.title,
    required this.storyCount,
    this.imageUrl,
    this.assetPath,
  });

  final String id;
  final String title;
  final int storyCount;
  final String? imageUrl;
  final String? assetPath;

  factory HomeCategoryModel.fromJson(Map<String, dynamic> json) {
    return HomeCategoryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      storyCount: (json['storyCount'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String?,
      assetPath: json['assetPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'storyCount': storyCount,
        'imageUrl': imageUrl,
        'assetPath': assetPath,
      };
}

class HomeStoryModel {
  const HomeStoryModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.coverUrl,
    this.assetPath,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? coverUrl;
  final String? assetPath;

  factory HomeStoryModel.fromJson(Map<String, dynamic> json) {
    return HomeStoryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? json['synopsis'] as String?,
      coverUrl: json['coverUrl'] as String?,
      assetPath: json['assetPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'coverUrl': coverUrl,
        'assetPath': assetPath,
      };
}

class ExploreMoreItem {
  const ExploreMoreItem({
    required this.id,
    required this.title,
    this.iconAsset,
    this.imageAsset,
    this.hasRoute = false,
    this.routeName,
  });

  final String id;
  final String title;
  final String? iconAsset;
  final String? imageAsset;
  final bool hasRoute;
  final String? routeName;
}

class HomeDataModel {
  const HomeDataModel({
    required this.greeting,
    required this.subtitle,
    required this.points,
    this.avatarUrl,
    this.banner,
    required this.categories,
    required this.popularStories,
    this.isEligibleForGame = false,
  });

  final String greeting;
  final String subtitle;
  final int points;
  final String? avatarUrl;
  final HomeBannerModel? banner;
  final List<HomeCategoryModel> categories;
  final List<HomeStoryModel> popularStories;
  final bool isEligibleForGame;

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    HomeBannerModel? banner;
    if (json['banner'] != null) {
      banner = HomeBannerModel.fromJson(
          Map<String, dynamic>.from(json['banner'] as Map));
    } else if (json['continueStory'] != null) {
      final cs = Map<String, dynamic>.from(json['continueStory'] as Map);
      final percent = (cs['percent'] as num?)?.toDouble() ?? 0.0;
      final currentChapter = cs['currentPageNumber'] ?? 1;
      final totalChapters = cs['chapterCount'] ?? 4;
      banner = HomeBannerModel(
        type: HomeBannerType.continueReading,
        title: 'Keep going!',
        subtitle: "You're doing great!",
        storyId: cs['storyId'] as String?,
        storyTitle: cs['title'] as String?,
        progressText: '$currentChapter/$totalChapters',
        progressPercent: percent > 1 ? percent / 100 : percent,
        buttonText: 'Continue',
        assetPath: 'assets/characters/home_banner_continue.png',
      );
    } else {
      banner = const HomeBannerModel(
        type: HomeBannerType.startReading,
        title: 'Start your first story!',
        subtitle: 'Unlock all power wings!',
        buttonText: 'Start Reading',
        assetPath: 'assets/characters/home_banner_reader.png',
      );
    }

    return HomeDataModel(
      greeting: json['greeting'] as String? ??
          (json['greetingName'] != null
              ? 'Hey ${json['greetingName']}!'
              : 'Hey Sarah!'),
      subtitle: json['subtitle'] as String? ?? 'Ready to learn today?',
      points: (json['points'] ?? json['pointsTotal'] as num?)?.toInt() ?? 0,
      avatarUrl: json['avatarUrl'] as String?,
      banner: banner,
      categories: (json['categories'] as List? ?? [])
          .map((e) =>
              HomeCategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      popularStories: (json['popularStories'] as List? ?? [])
          .map((e) =>
              HomeStoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      isEligibleForGame:
          json['isEligibleForGame'] ?? json['eligible'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'greeting': greeting,
        'subtitle': subtitle,
        'points': points,
        'avatarUrl': avatarUrl,
        'banner': banner?.toJson(),
        'categories': categories.map((e) => e.toJson()).toList(),
        'popularStories': popularStories.map((e) => e.toJson()).toList(),
        'isEligibleForGame': isEligibleForGame,
      };
}
