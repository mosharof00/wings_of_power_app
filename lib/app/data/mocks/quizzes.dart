import '../models/quiz_models.dart';

class QuizzesMock {
  QuizzesMock._();

  static Duration artificialDelay = const Duration(milliseconds: 300);
  static bool errorOverride = false;

  // Question definitions with hidden correct flags for mock scoring
  static const Map<String, String> _correctOptions = {
    'q1-faith-captain': 'opt-1a',
    'q2-sport': 'opt-2b',
    'q3-team-support': 'opt-3a',
    'q4-faith-feeling': 'opt-4b',
    'q5-kindness': 'opt-5b',
    'cp-q1': 'cp-opt-1a',
    'cp-q2': 'cp-opt-2a',
  };

  static final Map<String, QuizModel> _chapterQuizzes = {
    'gp1-ch-1': const QuizModel(
      id: 'quiz-gp1-ch-1',
      kind: 'CHAPTER',
      title: 'Chapter 1 Quiz',
      chapterId: 'gp1-ch-1',
      questions: [
        QuizQuestionModel(
          id: 'q1-faith-captain',
          sortOrder: 1,
          type: 'MCQ',
          prompt: 'Who was chosen as the team captain?',
          options: [
            QuizOptionModel(id: 'opt-1a', sortOrder: 1, label: 'Faith'),
            QuizOptionModel(id: 'opt-1b', sortOrder: 2, label: 'Mia'),
            QuizOptionModel(id: 'opt-1c', sortOrder: 3, label: 'Coach John'),
            QuizOptionModel(id: 'opt-1d', sortOrder: 4, label: 'Leo'),
          ],
        ),
        QuizQuestionModel(
          id: 'q2-sport',
          sortOrder: 2,
          type: 'MCQ',
          prompt: 'What sport were they playing together?',
          options: [
            QuizOptionModel(id: 'opt-2a', sortOrder: 1, label: 'Soccer'),
            QuizOptionModel(id: 'opt-2b', sortOrder: 2, label: 'Basketball'),
            QuizOptionModel(id: 'opt-2c', sortOrder: 3, label: 'Tennis'),
            QuizOptionModel(id: 'opt-2d', sortOrder: 4, label: 'Baseball'),
          ],
        ),
        QuizQuestionModel(
          id: 'q3-team-support',
          sortOrder: 3,
          type: 'MCQ',
          prompt: 'How can teammates support each other?',
          options: [
            QuizOptionModel(
              id: 'opt-3a',
              sortOrder: 1,
              label: 'By cheering and encouraging',
            ),
            QuizOptionModel(
              id: 'opt-3b',
              sortOrder: 2,
              label: 'By blaming others',
            ),
            QuizOptionModel(
              id: 'opt-3c',
              sortOrder: 3,
              label: 'By not passing the ball',
            ),
            QuizOptionModel(
              id: 'opt-3d',
              sortOrder: 4,
              label: 'By staying quiet',
            ),
          ],
        ),
        QuizQuestionModel(
          id: 'q4-faith-feeling',
          sortOrder: 4,
          type: 'MCQ',
          prompt:
              'How did Faith feel when she saw her name on the team list?',
          options: [
            QuizOptionModel(id: 'opt-4a', sortOrder: 1, label: 'Scared'),
            QuizOptionModel(
              id: 'opt-4b',
              sortOrder: 2,
              label: 'Happy & Proud',
            ),
            QuizOptionModel(id: 'opt-4c', sortOrder: 3, label: 'Bored'),
            QuizOptionModel(id: 'opt-4d', sortOrder: 4, label: 'Angry'),
          ],
        ),
        QuizQuestionModel(
          id: 'q5-kindness',
          sortOrder: 5,
          type: 'MCQ',
          prompt:
              'What is a kind thing to do if you see someone being left out?',
          options: [
            QuizOptionModel(id: 'opt-5a', sortOrder: 1, label: 'Ignore It'),
            QuizOptionModel(
              id: 'opt-5b',
              sortOrder: 2,
              label: 'Invite them to join',
            ),
            QuizOptionModel(id: 'opt-5c', sortOrder: 3, label: 'Laugh'),
            QuizOptionModel(
              id: 'opt-5d',
              sortOrder: 4,
              label: 'Tell them to leave',
            ),
          ],
        ),
      ],
    ),
  };

  static final Map<String, QuizModel> _checkpointQuizzes = {
    'gp1-ch-1': const QuizModel(
      id: 'checkpoint-gp1-ch-1',
      kind: 'CHECKPOINT',
      title: 'Chapter 1 Checkpoint',
      chapterId: 'gp1-ch-1',
      questions: [
        QuizQuestionModel(
          id: 'cp-q1',
          sortOrder: 1,
          type: 'MCQ',
          prompt: 'What did Faith say to Mia?',
          hint:
              'Remember when Faith saw Mia sitting alone? Faith smiled and spoke kindly.',
          explanation:
              'The answer is:\n“Want to sit with us?” Faith was being kind.',
          options: [
            QuizOptionModel(
              id: 'cp-opt-1a',
              sortOrder: 1,
              label: 'Want to sit with us?',
            ),
            QuizOptionModel(
              id: 'cp-opt-1b',
              sortOrder: 2,
              label: 'Let’s Play',
            ),
            QuizOptionModel(
              id: 'cp-opt-1c',
              sortOrder: 3,
              label: 'She walked past',
            ),
            QuizOptionModel(
              id: 'cp-opt-1d',
              sortOrder: 4,
              label: 'Go away',
            ),
          ],
        ),
        QuizQuestionModel(
          id: 'cp-q2',
          sortOrder: 2,
          type: 'TRUE_FALSE',
          prompt: 'Kind words can help someone feel included.',
          hint: 'Think about how it feels when someone says something nice to you.',
          explanation: 'The answer is True! Kind words always make others feel welcome.',
          options: [
            QuizOptionModel(id: 'cp-opt-2a', sortOrder: 1, label: 'True'),
            QuizOptionModel(id: 'cp-opt-2b', sortOrder: 2, label: 'False'),
          ],
        ),
      ],
    ),
  };

  // In-memory attempts state for mock mode
  static final Map<String, QuizAttemptModel> _activeAttempts = {};
  static final Map<String, List<Map<String, dynamic>>> _attemptAnswers = {};
  static int _attemptCounter = 1;

  static void reset() {
    errorOverride = false;
    _activeAttempts.clear();
    _attemptAnswers.clear();
    _attemptCounter = 1;
  }

  static Future<QuizModel> getChapterQuiz(String chapterId) async {
    if (artificialDelay.inMilliseconds > 0) {
      await Future.delayed(artificialDelay);
    }
    if (errorOverride) {
      throw Exception('Failed to load quiz');
    }
    final quiz = _chapterQuizzes[chapterId] ?? _chapterQuizzes['gp1-ch-1'];
    if (quiz == null) {
      throw Exception('Quiz not found for chapter: $chapterId');
    }
    return quiz;
  }

  static Future<QuizModel> getChapterCheckpoint(String chapterId) async {
    if (artificialDelay.inMilliseconds > 0) {
      await Future.delayed(artificialDelay);
    }
    if (errorOverride) {
      throw Exception('Failed to load checkpoint');
    }
    final quiz = _checkpointQuizzes[chapterId] ?? _checkpointQuizzes['gp1-ch-1'];
    if (quiz == null) {
      throw Exception('Checkpoint not found for chapter: $chapterId');
    }
    return quiz;
  }

  static Future<QuizAttemptModel> startQuizAttempt(String quizId) async {
    if (artificialDelay.inMilliseconds > 0) {
      await Future.delayed(artificialDelay);
    }
    if (errorOverride) {
      throw Exception('Failed to start attempt');
    }

    final id = 'attempt-${_attemptCounter++}';
    final attempt = QuizAttemptModel(
      id: id,
      quizId: quizId,
      userId: 'student-1',
      scoreCorrect: 0,
      scoreTotal: 0,
      pointsAwarded: 0,
      status: 'IN_PROGRESS',
    );
    _activeAttempts[id] = attempt;
    _attemptAnswers[id] = [];
    return attempt;
  }

  static Future<SubmitAnswerResponseModel> submitAnswer({
    required String attemptId,
    required String questionId,
    String? optionId,
    String? freeText,
  }) async {
    if (artificialDelay.inMilliseconds > 0) {
      await Future.delayed(artificialDelay);
    }
    if (errorOverride) {
      throw Exception('Failed to submit answer');
    }

    final answers = _attemptAnswers.putIfAbsent(attemptId, () => []);
    final existingQuestionAnswers =
        answers.where((a) => a['questionId'] == questionId).toList();
    final attemptIndex = existingQuestionAnswers.length + 1;

    final correctOptionId = _correctOptions[questionId];
    final isCorrect = optionId != null && optionId == correctOptionId;

    // Hints and explanations lookup
    String? hint;
    String? explanation;
    if (questionId == 'cp-q1') {
      hint =
          'Remember when Faith saw Mia sitting alone? Faith smiled and spoke kindly.';
      explanation =
          'The answer is:\n“Want to sit with us?” Faith was being kind.';
    } else if (questionId == 'cp-q2') {
      hint = 'Think about how it feels when someone says something nice to you.';
      explanation =
          'The answer is True! Kind words always make others feel welcome.';
    }

    answers.add({
      'questionId': questionId,
      'optionId': optionId,
      'isCorrect': isCorrect,
      'attemptIndex': attemptIndex,
    });

    return SubmitAnswerResponseModel(
      id: 'ans-${answers.length}',
      attemptId: attemptId,
      questionId: questionId,
      optionId: optionId,
      isCorrect: isCorrect,
      attemptIndex: attemptIndex,
      isFinished: isCorrect || attemptIndex >= 2,
      hint: hint,
      explanation: explanation,
      correctOptionId: correctOptionId,
    );
  }

  static Future<CompleteAttemptResponseModel> completeAttempt({
    required String attemptId,
    int? overrideScoreCorrect,
  }) async {
    if (artificialDelay.inMilliseconds > 0) {
      await Future.delayed(artificialDelay);
    }
    if (errorOverride) {
      throw Exception('Failed to complete attempt');
    }

    final answers = _attemptAnswers[attemptId] ?? [];
    int scoreCorrect = 0;
    if (overrideScoreCorrect != null) {
      scoreCorrect = overrideScoreCorrect;
    } else {
      final answeredQuestions = <String>{};
      for (final a in answers) {
        final qId = a['questionId'] as String;
        if (!answeredQuestions.contains(qId)) {
          if (a['isCorrect'] == true) {
            scoreCorrect++;
          }
          answeredQuestions.add(qId);
        }
      }
      if (answers.isEmpty) {
        scoreCorrect = 3; // Default realistic middle score
      }
    }

    const scoreTotal = 5;
    // 1/5 -> 2, 3/5 -> 6, 5/5 -> 10 (2 points per correct question)
    final pointsAwarded = scoreCorrect * 2;
    final quizBestPercent = (scoreCorrect / scoreTotal * 100).round();

    return CompleteAttemptResponseModel(
      id: attemptId,
      quizId: 'quiz-gp1-ch-1',
      scoreCorrect: scoreCorrect,
      scoreTotal: scoreTotal,
      pointsAwarded: pointsAwarded,
      status: 'COMPLETED',
      quizBestPercent: quizBestPercent,
    );
  }

  // Predefined Result Fixtures for Testing & Route Demonstration
  static CompleteAttemptResponseModel getFixtureResult(String scenario) {
    switch (scenario) {
      case '1/5':
      case 'fail':
        return const CompleteAttemptResponseModel(
          id: 'attempt-fail-1',
          quizId: 'quiz-gp1-ch-1',
          scoreCorrect: 1,
          scoreTotal: 5,
          pointsAwarded: 2,
          status: 'COMPLETED',
          quizBestPercent: 20,
        );
      case '5/5':
      case 'perfect':
        return const CompleteAttemptResponseModel(
          id: 'attempt-perfect-1',
          quizId: 'quiz-gp1-ch-1',
          scoreCorrect: 5,
          scoreTotal: 5,
          pointsAwarded: 10,
          status: 'COMPLETED',
          quizBestPercent: 100,
        );
      case '3/5':
      case 'pass':
      default:
        return const CompleteAttemptResponseModel(
          id: 'attempt-pass-1',
          quizId: 'quiz-gp1-ch-1',
          scoreCorrect: 3,
          scoreTotal: 5,
          pointsAwarded: 6,
          status: 'COMPLETED',
          quizBestPercent: 60,
        );
    }
  }
}
