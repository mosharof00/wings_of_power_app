import 'package:get/get.dart';
import '../../../data/models/quiz_models.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../routes/app_pages.dart';

class QuizController extends GetxController {
  QuizController(this._repository);

  final IQuizRepository _repository;

  String storyId = 'story-golden-pearl-1';
  String chapterId = 'gp1-ch-1';
  String attemptId = '';

  final isLoading = true.obs;
  final isError = false.obs;
  final errorMessage = ''.obs;

  // Chapter quiz observables
  final quiz = Rxn<QuizModel>();
  final currentQuestionIndex = 0.obs;
  final selectedOptionId = RxnString();
  final isAnswerChecked = false.obs;
  final isAnswerCorrect = false.obs;
  final correctOptionId = RxnString();
  final scoreCorrect = 0.obs;
  final scoreTotal = 5.obs;
  final pointsAwarded = 0.obs;
  final quizBestPercent = 60.obs;
  final isTtsSpeaking = false.obs;

  // Checkpoint observables
  final checkpointQuiz = Rxn<QuizModel>();
  final checkpointQuestionIndex = 0.obs;
  final selectedCheckpointOptionId = RxnString();
  final checkpointAttemptCount = 0.obs;
  final checkpointHint = RxnString();
  final checkpointExplanation = RxnString();
  final isCheckpointSubmitting = false.obs;

  int get totalQuestions => quiz.value?.questions.length ?? 5;
  int get currentQuestionNumber => currentQuestionIndex.value + 1;
  bool get isLastQuestion =>
      totalQuestions > 0 && currentQuestionIndex.value >= totalQuestions - 1;

  QuizQuestionModel? get currentQuestion {
    final questions = quiz.value?.questions;
    if (questions == null || questions.isEmpty) return null;
    if (currentQuestionIndex.value < 0 ||
        currentQuestionIndex.value >= questions.length) {
      return null;
    }
    return questions[currentQuestionIndex.value];
  }

  QuizQuestionModel? get currentCheckpointQuestion {
    final questions = checkpointQuiz.value?.questions;
    if (questions == null || questions.isEmpty) return null;
    if (checkpointQuestionIndex.value < 0 ||
        checkpointQuestionIndex.value >= questions.length) {
      return null;
    }
    return questions[checkpointQuestionIndex.value];
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      if (args['storyId'] != null) {
        storyId = args['storyId'].toString();
      }
      if (args['chapterId'] != null) {
        chapterId = args['chapterId'].toString();
      }
      if (args['scenario'] != null) {
        _applyScenario(args['scenario'].toString());
      }
      if (args['scoreCorrect'] != null) {
        scoreCorrect.value =
            int.tryParse(args['scoreCorrect'].toString()) ?? 3;
        pointsAwarded.value = scoreCorrect.value * 2;
      }
      if (args['scoreTotal'] != null) {
        scoreTotal.value =
            int.tryParse(args['scoreTotal'].toString()) ?? 5;
      }
    }
  }

  void _applyScenario(String scenario) {
    if (scenario == '1/5' || scenario == 'fail') {
      scoreCorrect.value = 1;
      scoreTotal.value = 5;
      pointsAwarded.value = 2;
    } else if (scenario == '5/5' || scenario == 'perfect') {
      scoreCorrect.value = 5;
      scoreTotal.value = 5;
      pointsAwarded.value = 10;
    } else {
      scoreCorrect.value = 3;
      scoreTotal.value = 5;
      pointsAwarded.value = 6;
    }
  }

  Future<void> loadChapterQuiz() async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';
    currentQuestionIndex.value = 0;
    selectedOptionId.value = null;
    isAnswerChecked.value = false;
    isAnswerCorrect.value = false;
    correctOptionId.value = null;
    scoreCorrect.value = 0;

    try {
      final loadedQuiz = await _repository.getChapterQuiz(chapterId);
      quiz.value = loadedQuiz;
      scoreTotal.value = loadedQuiz.questions.length;

      final attempt = await _repository.startQuizAttempt(loadedQuiz.id);
      attemptId = attempt.id;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      isError.value = true;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    }
  }

  void selectOption(String optionId) {
    if (isAnswerChecked.value) return;
    selectedOptionId.value = optionId;
  }

  Future<void> checkAnswer() async {
    final optionId = selectedOptionId.value;
    final question = currentQuestion;
    if (optionId == null || question == null || isAnswerChecked.value) return;

    try {
      final res = await _repository.submitAnswer(
        attemptId: attemptId.isNotEmpty ? attemptId : 'mock-attempt',
        questionId: question.id,
        optionId: optionId,
      );

      isAnswerChecked.value = true;
      isAnswerCorrect.value = res.isCorrect;
      correctOptionId.value = res.correctOptionId ??
          (res.isCorrect ? optionId : _findCorrectOptionId(question, res));

      if (res.isCorrect) {
        scoreCorrect.value++;
      }
    } catch (e) {
      // In case of error, still advance state for smooth experience
      isAnswerChecked.value = true;
      isAnswerCorrect.value = false;
    }
  }

  String? _findCorrectOptionId(
      QuizQuestionModel question, SubmitAnswerResponseModel res) {
    if (res.correctOptionId != null) return res.correctOptionId;
    return null;
  }

  void nextQuestion() {
    if (isLastQuestion) {
      seeResult();
      return;
    }
    currentQuestionIndex.value++;
    selectedOptionId.value = null;
    isAnswerChecked.value = false;
    isAnswerCorrect.value = false;
    correctOptionId.value = null;
  }

  Future<void> seeResult() async {
    isLoading.value = true;
    try {
      final res = await _repository.completeAttempt(
        attemptId: attemptId.isNotEmpty ? attemptId : 'mock-attempt',
        overrideScoreCorrect: scoreCorrect.value,
      );
      pointsAwarded.value = res.pointsAwarded;
      quizBestPercent.value = res.quizBestPercent ??
          (scoreTotal.value > 0
              ? (scoreCorrect.value / scoreTotal.value * 100).round()
              : 60);

      isLoading.value = false;
      Get.offNamed(
        Routes.CHAPTER_QUIZ_RESULT,
        arguments: {
          'storyId': storyId,
          'chapterId': chapterId,
          'scoreCorrect': scoreCorrect.value,
          'scoreTotal': scoreTotal.value,
          'pointsAwarded': pointsAwarded.value,
        },
      );
    } catch (e) {
      isLoading.value = false;
      Get.offNamed(
        Routes.CHAPTER_QUIZ_RESULT,
        arguments: {
          'storyId': storyId,
          'chapterId': chapterId,
          'scoreCorrect': scoreCorrect.value,
          'scoreTotal': scoreTotal.value,
          'pointsAwarded': scoreCorrect.value * 2,
        },
      );
    }
  }

  void toggleSpeaker() {
    isTtsSpeaking.value = !isTtsSpeaking.value;
  }

  void playAgain() {
    Get.offNamed(
      Routes.CHAPTER_QUIZ,
      arguments: {
        'storyId': storyId,
        'chapterId': chapterId,
      },
    );
  }

  void nextChapter() {
    // If chapterId is gp1-ch-1, next chapter is gp1-ch-2
    final nextId = chapterId == 'gp1-ch-1' ? 'gp1-ch-2' : null;
    if (nextId != null) {
      Get.offNamed(
        Routes.STORY_READER,
        arguments: {
          'storyId': storyId,
          'chapterId': nextId,
        },
      );
    } else {
      backToStory();
    }
  }

  void backToStory() {
    Get.offNamed(
      Routes.STORY_DETAILS,
      arguments: {'storyId': storyId},
    );
  }

  void leaveQuiz() {
    backToStory();
  }

  // --- CHECKPOINT METHODS ---

  Future<void> loadCheckpointQuiz() async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';
    checkpointQuestionIndex.value = 0;
    selectedCheckpointOptionId.value = null;
    checkpointAttemptCount.value = 0;
    checkpointHint.value = null;
    checkpointExplanation.value = null;

    try {
      final loadedQuiz = await _repository.getChapterCheckpoint(chapterId);
      checkpointQuiz.value = loadedQuiz;
      final attempt = await _repository.startQuizAttempt(loadedQuiz.id);
      attemptId = attempt.id;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      isError.value = true;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    }
  }

  void selectCheckpointOption(String optionId) {
    selectedCheckpointOptionId.value = optionId;
  }

  Future<SubmitAnswerResponseModel?> submitCheckpointAnswer() async {
    final optionId = selectedCheckpointOptionId.value;
    final question = currentCheckpointQuestion;
    if (optionId == null || question == null) return null;

    isCheckpointSubmitting.value = true;
    checkpointAttemptCount.value++;

    try {
      final res = await _repository.submitAnswer(
        attemptId: attemptId.isNotEmpty ? attemptId : 'mock-checkpoint-attempt',
        questionId: question.id,
        optionId: optionId,
      );

      checkpointHint.value = res.hint ?? question.hint;
      checkpointExplanation.value = res.explanation ?? question.explanation;
      isCheckpointSubmitting.value = false;
      return res;
    } catch (e) {
      isCheckpointSubmitting.value = false;
      return null;
    }
  }
}
