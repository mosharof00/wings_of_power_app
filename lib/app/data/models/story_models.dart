class ChapterModel {
  const ChapterModel({
    required this.id,
    required this.storyId,
    required this.chapterNumber,
    required this.title,
    this.pageCount = 15,
    this.estimatedMinutes = 3,
    this.isLocked = false,
    this.isCompleted = false,
    this.progressPercent,
    this.hasQuiz = false,
    this.quizId,
    this.quizScore,
    this.coverUrl,
    this.assetPath,
  });

  final String id;
  final String storyId;
  final int chapterNumber;
  final String title;
  final int pageCount;
  final int estimatedMinutes;
  final bool isLocked;
  final bool isCompleted;
  final double? progressPercent;
  final bool hasQuiz;
  final String? quizId;
  final int? quizScore;
  final String? coverUrl;
  final String? assetPath;

  ChapterModel copyWith({
    String? id,
    String? storyId,
    int? chapterNumber,
    String? title,
    int? pageCount,
    int? estimatedMinutes,
    bool? isLocked,
    bool? isCompleted,
    double? progressPercent,
    bool? hasQuiz,
    String? quizId,
    int? quizScore,
    String? coverUrl,
    String? assetPath,
  }) {
    return ChapterModel(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      title: title ?? this.title,
      pageCount: pageCount ?? this.pageCount,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isLocked: isLocked ?? this.isLocked,
      isCompleted: isCompleted ?? this.isCompleted,
      progressPercent: progressPercent ?? this.progressPercent,
      hasQuiz: hasQuiz ?? this.hasQuiz,
      quizId: quizId ?? this.quizId,
      quizScore: quizScore ?? this.quizScore,
      coverUrl: coverUrl ?? this.coverUrl,
      assetPath: assetPath ?? this.assetPath,
    );
  }

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'] as String? ?? '',
      storyId: json['storyId'] as String? ?? '',
      chapterNumber: (json['chapterNumber'] ?? json['order'] as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? '',
      pageCount: (json['pageCount'] ?? json['pages'] as num?)?.toInt() ?? 15,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 3,
      isLocked: json['isLocked'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      progressPercent: (json['progressPercent'] as num?)?.toDouble(),
      hasQuiz: json['hasQuiz'] as bool? ?? false,
      quizId: json['quizId'] as String?,
      quizScore: (json['quizScore'] as num?)?.toInt(),
      coverUrl: json['coverUrl'] as String?,
      assetPath: json['assetPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'storyId': storyId,
        'chapterNumber': chapterNumber,
        'title': title,
        'pageCount': pageCount,
        'estimatedMinutes': estimatedMinutes,
        'isLocked': isLocked,
        'isCompleted': isCompleted,
        'progressPercent': progressPercent,
        'hasQuiz': hasQuiz,
        'quizId': quizId,
        'quizScore': quizScore,
        'coverUrl': coverUrl,
        'assetPath': assetPath,
      };
}

class StorySummaryModel {
  const StorySummaryModel({
    required this.id,
    required this.title,
    this.author,
    this.synopsis,
    required this.category,
    required this.ageGroup,
    this.coverUrl,
    this.assetPath,
    this.chapterCount = 0,
    this.estimatedMinutes = 10,
    this.progressPercent,
    this.isLocked = false,
  });

  final String id;
  final String title;
  final String? author;
  final String? synopsis;
  final String category;
  final String ageGroup;
  final String? coverUrl;
  final String? assetPath;
  final int chapterCount;
  final int estimatedMinutes;
  final double? progressPercent;
  final bool isLocked;

  factory StorySummaryModel.fromJson(Map<String, dynamic> json) {
    return StorySummaryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String?,
      synopsis: json['synopsis'] as String? ?? json['description'] as String?,
      category: json['category'] as String? ?? 'Kindness',
      ageGroup: json['ageGroup'] as String? ?? '6-9',
      coverUrl: json['coverUrl'] as String?,
      assetPath: json['assetPath'] as String?,
      chapterCount: (json['chapterCount'] as num?)?.toInt() ?? 0,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 10,
      progressPercent: (json['progressPercent'] as num?)?.toDouble(),
      isLocked: json['isLocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'synopsis': synopsis,
        'category': category,
        'ageGroup': ageGroup,
        'coverUrl': coverUrl,
        'assetPath': assetPath,
        'chapterCount': chapterCount,
        'estimatedMinutes': estimatedMinutes,
        'progressPercent': progressPercent,
        'isLocked': isLocked,
      };
}

class StoryDetailModel {
  const StoryDetailModel({
    required this.id,
    required this.title,
    required this.author,
    required this.synopsis,
    required this.category,
    required this.ageGroup,
    this.coverUrl,
    this.assetPath,
    required this.chapterCount,
    required this.estimatedMinutes,
    required this.chapters,
    this.isStarted = false,
    this.isCompleted = false,
    this.currentChapterId,
    this.overallPercent = 0.0,
  });

  final String id;
  final String title;
  final String author;
  final String synopsis;
  final String category;
  final String ageGroup;
  final String? coverUrl;
  final String? assetPath;
  final int chapterCount;
  final int estimatedMinutes;
  final List<ChapterModel> chapters;
  final bool isStarted;
  final bool isCompleted;
  final String? currentChapterId;
  final double overallPercent;

  factory StoryDetailModel.fromJson(Map<String, dynamic> json) {
    final rawChapters = (json['chapters'] as List? ?? []);
    final chaptersList = rawChapters
        .map((e) => ChapterModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return StoryDetailModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? 'Audrey Cuff Ed. D.',
      synopsis: json['synopsis'] as String? ??
          json['description'] as String? ??
          'The sound of the school bell rings, and all the children run out of Kramer School with glee.',
      category: json['category'] as String? ?? 'Kindness',
      ageGroup: json['ageGroup'] as String? ?? '6-9',
      coverUrl: json['coverUrl'] as String?,
      assetPath: json['assetPath'] as String?,
      chapterCount: (json['chapterCount'] as num?)?.toInt() ?? chaptersList.length,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 10,
      chapters: chaptersList,
      isStarted: json['isStarted'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      currentChapterId: json['currentChapterId'] as String?,
      overallPercent: (json['overallPercent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'synopsis': synopsis,
        'category': category,
        'ageGroup': ageGroup,
        'coverUrl': coverUrl,
        'assetPath': assetPath,
        'chapterCount': chapterCount,
        'estimatedMinutes': estimatedMinutes,
        'chapters': chapters.map((e) => e.toJson()).toList(),
        'isStarted': isStarted,
        'isCompleted': isCompleted,
        'currentChapterId': currentChapterId,
        'overallPercent': overallPercent,
      };
}

class StoryListResponse {
  const StoryListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.perPage,
    required this.lastPage,
  });

  final List<StorySummaryModel> items;
  final int total;
  final int page;
  final int perPage;
  final int lastPage;

  factory StoryListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['items'] as List? ?? [])
        .map((e) =>
            StorySummaryModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return StoryListResponse(
      items: list,
      total: (json['total'] as num?)?.toInt() ?? list.length,
      page: (json['page'] as num?)?.toInt() ?? 1,
      perPage: (json['perPage'] as num?)?.toInt() ?? 20,
      lastPage: (json['lastPage'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        'total': total,
        'page': page,
        'perPage': perPage,
        'lastPage': lastPage,
      };
}

class ChapterPageModel {
  const ChapterPageModel({
    required this.number,
    this.id,
    this.chapterId,
    this.bodyText = '',
    this.imageUrl,
    this.assetPath,
    this.hasCheckpoint = false,
    this.checkpointId,
  });

  final int number;
  final String? id;
  final String? chapterId;
  final String bodyText;
  final String? imageUrl;
  final String? assetPath;
  final bool hasCheckpoint;
  final String? checkpointId;

  ChapterPageModel copyWith({
    int? number,
    String? id,
    String? chapterId,
    String? bodyText,
    String? imageUrl,
    String? assetPath,
    bool? hasCheckpoint,
    String? checkpointId,
  }) {
    return ChapterPageModel(
      number: number ?? this.number,
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      bodyText: bodyText ?? this.bodyText,
      imageUrl: imageUrl ?? this.imageUrl,
      assetPath: assetPath ?? this.assetPath,
      hasCheckpoint: hasCheckpoint ?? this.hasCheckpoint,
      checkpointId: checkpointId ?? this.checkpointId,
    );
  }

  factory ChapterPageModel.fromJson(Map<String, dynamic> json) {
    return ChapterPageModel(
      number: (json['number'] ?? json['pageNumber'] as num?)?.toInt() ?? 1,
      id: json['id'] as String?,
      chapterId: json['chapterId'] ?? json['chapter_id'] as String?,
      bodyText: json['bodyText'] ?? json['body_text'] as String? ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'] as String?,
      assetPath: json['assetPath'] as String?,
      hasCheckpoint: json['hasCheckpoint'] as bool? ?? false,
      checkpointId: json['checkpointId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        if (id != null) 'id': id,
        if (chapterId != null) 'chapterId': chapterId,
        'bodyText': bodyText,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (assetPath != null) 'assetPath': assetPath,
        'hasCheckpoint': hasCheckpoint,
        if (checkpointId != null) 'checkpointId': checkpointId,
      };
}

class ChapterDetailModel {
  const ChapterDetailModel({
    required this.id,
    required this.storyId,
    required this.chapterNumber,
    required this.title,
    this.audioUrl,
    this.durationMs,
    this.pages = const [],
    this.isCompleted = false,
    this.hasQuiz = false,
    this.quizId,
  });

  final String id;
  final String storyId;
  final int chapterNumber;
  final String title;
  final String? audioUrl;
  final int? durationMs;
  final List<ChapterPageModel> pages;
  final bool isCompleted;
  final bool hasQuiz;
  final String? quizId;

  int get pageCount => pages.length;

  ChapterDetailModel copyWith({
    String? id,
    String? storyId,
    int? chapterNumber,
    String? title,
    String? audioUrl,
    int? durationMs,
    List<ChapterPageModel>? pages,
    bool? isCompleted,
    bool? hasQuiz,
    String? quizId,
  }) {
    return ChapterDetailModel(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      title: title ?? this.title,
      audioUrl: audioUrl ?? this.audioUrl,
      durationMs: durationMs ?? this.durationMs,
      pages: pages ?? this.pages,
      isCompleted: isCompleted ?? this.isCompleted,
      hasQuiz: hasQuiz ?? this.hasQuiz,
      quizId: quizId ?? this.quizId,
    );
  }

  factory ChapterDetailModel.fromJson(Map<String, dynamic> json) {
    final rawPages = (json['pages'] as List? ?? []);
    final pagesList = rawPages
        .map((e) =>
            ChapterPageModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    pagesList.sort((a, b) => a.number.compareTo(b.number));

    return ChapterDetailModel(
      id: json['id'] as String? ?? '',
      storyId: json['storyId'] ?? json['story_id'] as String? ?? '',
      chapterNumber:
          (json['chapterNumber'] ?? json['number'] as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? '',
      audioUrl: json['audioUrl'] ??
          json['audio_url'] ??
          (json['audio'] is Map ? json['audio']['audioUrl'] as String? : null),
      durationMs: (json['durationMs'] ??
              json['duration_ms'] ??
              (json['audio'] is Map
                  ? json['audio']['durationMs'] as num?
                  : null))
          ?.toInt(),
      pages: pagesList,
      isCompleted: json['isCompleted'] as bool? ?? false,
      hasQuiz: json['hasQuiz'] as bool? ?? false,
      quizId: json['quizId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'storyId': storyId,
        'chapterNumber': chapterNumber,
        'title': title,
        if (audioUrl != null) 'audioUrl': audioUrl,
        if (durationMs != null) 'durationMs': durationMs,
        'pages': pages.map((e) => e.toJson()).toList(),
        'isCompleted': isCompleted,
        'hasQuiz': hasQuiz,
        if (quizId != null) 'quizId': quizId,
      };
}

