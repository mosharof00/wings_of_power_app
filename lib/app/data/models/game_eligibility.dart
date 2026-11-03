class GameEligibilityModel {
  final bool eligible;
  final GameEligibilityProgress progress;
  final GameEligibilityRules rules;

  GameEligibilityModel({
    required this.eligible,
    required this.progress,
    required this.rules,
  });

  factory GameEligibilityModel.fromJson(Map<String, dynamic> json) {
    return GameEligibilityModel(
      eligible: json['eligible'] == true,
      progress: GameEligibilityProgress.fromJson(
        json['progress'] is Map<String, dynamic>
            ? json['progress'] as Map<String, dynamic>
            : (json['progress'] is Map
                ? Map<String, dynamic>.from(json['progress'] as Map)
                : <String, dynamic>{}),
      ),
      rules: GameEligibilityRules.fromJson(
        json['rules'] is Map<String, dynamic>
            ? json['rules'] as Map<String, dynamic>
            : (json['rules'] is Map
                ? Map<String, dynamic>.from(json['rules'] as Map)
                : <String, dynamic>{}),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'eligible': eligible,
        'progress': progress.toJson(),
        'rules': rules.toJson(),
      };
}

class GameEligibilityProgress {
  final int storiesCompleted;
  final int chaptersCompleted;
  final double bestQuizPercent;

  GameEligibilityProgress({
    this.storiesCompleted = 0,
    this.chaptersCompleted = 0,
    this.bestQuizPercent = 0.0,
  });

  factory GameEligibilityProgress.fromJson(Map<String, dynamic> json) {
    final quizVal = json['bestQuizPercent'] ?? json['quizMean'] ?? 0;
    return GameEligibilityProgress(
      storiesCompleted: (json['storiesCompleted'] as num?)?.toInt() ??
          (json['completedStories'] as num?)?.toInt() ??
          0,
      chaptersCompleted: (json['chaptersCompleted'] as num?)?.toInt() ??
          (json['completedChapters'] as num?)?.toInt() ??
          0,
      bestQuizPercent: (quizVal as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'storiesCompleted': storiesCompleted,
        'chaptersCompleted': chaptersCompleted,
        'bestQuizPercent': bestQuizPercent,
      };
}

class GameEligibilityRules {
  final int requiredStories;
  final int requiredChapters;
  final int minQuizPercent;

  GameEligibilityRules({
    this.requiredStories = 2,
    this.requiredChapters = 6,
    this.minQuizPercent = 70,
  });

  factory GameEligibilityRules.fromJson(Map<String, dynamic> json) {
    return GameEligibilityRules(
      requiredStories: (json['requiredStories'] as num?)?.toInt() ??
          (json['required_stories'] as num?)?.toInt() ??
          2,
      requiredChapters: (json['requiredChapters'] as num?)?.toInt() ??
          (json['required_chapters'] as num?)?.toInt() ??
          6,
      minQuizPercent: (json['minQuizPercent'] as num?)?.toInt() ??
          (json['min_quiz_percent'] as num?)?.toInt() ??
          70,
    );
  }

  Map<String, dynamic> toJson() => {
        'requiredStories': requiredStories,
        'requiredChapters': requiredChapters,
        'minQuizPercent': minQuizPercent,
      };
}

