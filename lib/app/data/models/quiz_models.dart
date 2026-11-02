class QuizOptionModel {
  const QuizOptionModel({
    required this.id,
    required this.sortOrder,
    required this.label,
  });

  final String id;
  final int sortOrder;
  final String label;

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) {
    return QuizOptionModel(
      id: json['id'] as String? ?? '',
      sortOrder: (json['sortOrder'] ?? json['sort_order'] as num?)?.toInt() ?? 0,
      label: json['label'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sortOrder': sortOrder,
        'label': label,
      };
}

class QuizQuestionModel {
  const QuizQuestionModel({
    required this.id,
    required this.sortOrder,
    this.type = 'MCQ',
    required this.prompt,
    required this.options,
    this.hint,
    this.explanation,
  });

  final String id;
  final int sortOrder;
  final String type;
  final String prompt;
  final List<QuizOptionModel> options;
  final String? hint;
  final String? explanation;

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = (json['options'] as List? ?? [])
        .map((e) => QuizOptionModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return QuizQuestionModel(
      id: json['id'] as String? ?? '',
      sortOrder: (json['sortOrder'] ?? json['sort_order'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? 'MCQ',
      prompt: json['prompt'] as String? ?? '',
      options: rawOptions,
      hint: json['hint'] as String?,
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sortOrder': sortOrder,
        'type': type,
        'prompt': prompt,
        'options': options.map((e) => e.toJson()).toList(),
        if (hint != null) 'hint': hint,
        if (explanation != null) 'explanation': explanation,
      };
}

class QuizModel {
  const QuizModel({
    required this.id,
    this.kind = 'CHAPTER',
    this.title,
    required this.chapterId,
    required this.questions,
  });

  final String id;
  final String kind;
  final String? title;
  final String chapterId;
  final List<QuizQuestionModel> questions;

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    final rawQuestions = (json['questions'] as List? ?? [])
        .map((e) =>
            QuizQuestionModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return QuizModel(
      id: json['id'] as String? ?? '',
      kind: json['kind'] as String? ?? 'CHAPTER',
      title: json['title'] as String?,
      chapterId: json['chapterId'] ?? json['chapter_id'] as String? ?? '',
      questions: rawQuestions,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        if (title != null) 'title': title,
        'chapterId': chapterId,
        'questions': questions.map((e) => e.toJson()).toList(),
      };
}

class QuizAttemptModel {
  const QuizAttemptModel({
    required this.id,
    required this.quizId,
    this.userId = '',
    this.scoreCorrect = 0,
    this.scoreTotal = 0,
    this.pointsAwarded = 0,
    this.status = 'IN_PROGRESS',
    this.quizBestPercent,
  });

  final String id;
  final String quizId;
  final String userId;
  final int scoreCorrect;
  final int scoreTotal;
  final int pointsAwarded;
  final String status;
  final int? quizBestPercent;

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptModel(
      id: json['id'] as String? ?? '',
      quizId: json['quizId'] ?? json['quiz_id'] as String? ?? '',
      userId: json['userId'] ?? json['user_id'] as String? ?? '',
      scoreCorrect:
          (json['scoreCorrect'] ?? json['score_correct'] as num?)?.toInt() ?? 0,
      scoreTotal:
          (json['scoreTotal'] ?? json['score_total'] as num?)?.toInt() ?? 0,
      pointsAwarded:
          (json['pointsAwarded'] ?? json['points_awarded'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'IN_PROGRESS',
      quizBestPercent: (json['quizBestPercent'] ?? json['quiz_best_percent'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'quizId': quizId,
        'userId': userId,
        'scoreCorrect': scoreCorrect,
        'scoreTotal': scoreTotal,
        'pointsAwarded': pointsAwarded,
        'status': status,
        if (quizBestPercent != null) 'quizBestPercent': quizBestPercent,
      };
}

class SubmitAnswerResponseModel {
  const SubmitAnswerResponseModel({
    required this.id,
    required this.attemptId,
    required this.questionId,
    this.optionId,
    required this.isCorrect,
    this.attemptIndex = 1,
    this.isFinished = true,
    this.hint,
    this.explanation,
    this.correctOptionId,
  });

  final String id;
  final String attemptId;
  final String questionId;
  final String? optionId;
  final bool isCorrect;
  final int attemptIndex;
  final bool isFinished;
  final String? hint;
  final String? explanation;
  final String? correctOptionId;

  factory SubmitAnswerResponseModel.fromJson(Map<String, dynamic> json) {
    return SubmitAnswerResponseModel(
      id: json['id'] as String? ?? '',
      attemptId: json['attemptId'] ?? json['attempt_id'] as String? ?? '',
      questionId: json['questionId'] ?? json['question_id'] as String? ?? '',
      optionId: json['optionId'] ?? json['option_id'] as String?,
      isCorrect: json['isCorrect'] ?? json['is_correct'] as bool? ?? false,
      attemptIndex:
          (json['attemptIndex'] ?? json['attempt_index'] as num?)?.toInt() ?? 1,
      isFinished: json['isFinished'] ?? json['is_finished'] as bool? ?? true,
      hint: json['hint'] as String?,
      explanation: json['explanation'] as String?,
      correctOptionId: json['correctOptionId'] ?? json['correct_option_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'attemptId': attemptId,
        'questionId': questionId,
        if (optionId != null) 'optionId': optionId,
        'isCorrect': isCorrect,
        'attemptIndex': attemptIndex,
        'isFinished': isFinished,
        if (hint != null) 'hint': hint,
        if (explanation != null) 'explanation': explanation,
        if (correctOptionId != null) 'correctOptionId': correctOptionId,
      };
}

class CompleteAttemptResponseModel {
  const CompleteAttemptResponseModel({
    required this.id,
    required this.quizId,
    required this.scoreCorrect,
    required this.scoreTotal,
    required this.pointsAwarded,
    this.status = 'COMPLETED',
    this.quizBestPercent,
    this.badge,
  });

  final String id;
  final String quizId;
  final int scoreCorrect;
  final int scoreTotal;
  final int pointsAwarded;
  final String status;
  final int? quizBestPercent;
  final Map<String, dynamic>? badge;

  factory CompleteAttemptResponseModel.fromJson(Map<String, dynamic> json) {
    return CompleteAttemptResponseModel(
      id: json['id'] as String? ?? '',
      quizId: json['quizId'] ?? json['quiz_id'] as String? ?? '',
      scoreCorrect:
          (json['scoreCorrect'] ?? json['score_correct'] as num?)?.toInt() ?? 0,
      scoreTotal:
          (json['scoreTotal'] ?? json['score_total'] as num?)?.toInt() ?? 0,
      pointsAwarded:
          (json['pointsAwarded'] ?? json['points_awarded'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'COMPLETED',
      quizBestPercent: (json['quizBestPercent'] ?? json['quiz_best_percent'] as num?)?.toInt(),
      badge: json['badge'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'quizId': quizId,
        'scoreCorrect': scoreCorrect,
        'scoreTotal': scoreTotal,
        'pointsAwarded': pointsAwarded,
        'status': status,
        if (quizBestPercent != null) 'quizBestPercent': quizBestPercent,
        if (badge != null) 'badge': badge,
      };
}

