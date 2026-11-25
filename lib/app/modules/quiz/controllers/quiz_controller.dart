import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/helper_utils.dart';
import '../../../data/models/quiz_models.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../data/repositories/story_repository.dart';
import '../../stories/controllers/stories_controller.dart';
import '../../../routes/app_pages.dart';

class QuizController extends GetxController {
  QuizController(this._repository, {this.isCheckpoint = false});

  final IQuizRepository _repository;

  final bool isCheckpoint;
  String storyId = '';
  String chapterId = '';
  String attemptId = '';
  bool _fromReader = false;
  bool _isLeaving = false;
  bool _isLoadingQuiz = false;
  final _answeredQuestions = <String>{};

  final isLoading = true.obs;
  final isError = false.obs;
  final isQuizUnavailable = false.obs;
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
  final result = Rxn<CompleteAttemptResponseModel>();
  final isSubmitting = false.obs;
  final submitError = ''.obs;
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
      totalQuestions > 0 && _answeredQuestions.length == totalQuestions;

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
      storyId = args['storyId']?.toString() ?? '';
      chapterId = args['chapterId']?.toString() ?? '';
      _fromReader = args['fromReader'] == true;
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (isClosed || _isLeaving) return;
    if (isCheckpoint) {
      loadCheckpointQuiz();
    } else {
      loadChapterQuiz();
    }
  }

  Future<void> loadChapterQuiz() async {
    if (_isLoadingQuiz || _isLeaving) return;
    _isLoadingQuiz = true;
    isLoading.value = true;
    result.value = null;
    _answeredQuestions.clear();
    isError.value = false;
    isQuizUnavailable.value = false;
    errorMessage.value = '';
    submitError.value = '';
    currentQuestionIndex.value = 0;
    selectedOptionId.value = null;
    isAnswerChecked.value = false;
    isAnswerCorrect.value = false;
    correctOptionId.value = null;
    scoreCorrect.value = 0;
    scoreTotal.value = 0;
    quiz.value = null;
    attemptId = '';

    QuizModel? loadedQuiz;
    try {
      if (chapterId.isEmpty) {
        throw ApiException('Open the quiz from a story chapter.');
      }
      loadedQuiz = await _repository.getChapterQuiz(chapterId);
      if (isClosed || _isLeaving) return;
      if (loadedQuiz.questions.isEmpty) {
        isQuizUnavailable.value = true;
        return;
      }
      if (loadedQuiz.id.isEmpty) {
        throw ApiException('Could not load the quiz. Please try again.');
      }

      final attempt = await _repository.startQuizAttempt(loadedQuiz.id);
      if (isClosed || _isLeaving) return;
      quiz.value = loadedQuiz;
      scoreTotal.value = loadedQuiz.questions.length;
      attemptId = attempt.id;
      _restoreAnswers(loadedQuiz.questions, attempt.answers);
    } catch (e) {
      if (isClosed || _isLeaving) return;
      if (loadedQuiz == null && e is ApiException && e.statusCode == 404) {
        isQuizUnavailable.value = true;
        return;
      }
      isError.value = true;
      errorMessage.value = _message(
        e,
        'Could not load the quiz. Please try again.',
      );
    } finally {
      _isLoadingQuiz = false;
      if (!isClosed && !_isLeaving) isLoading.value = false;
    }
  }

  void _restoreAnswers(
    List<QuizQuestionModel> questions,
    List<SubmitAnswerResponseModel> answers,
  ) {
    final byQuestion = {
      for (final answer in answers) answer.questionId: answer,
    };
    for (final question in questions) {
      final answer = byQuestion[question.id];
      if (answer == null) continue;
      _answeredQuestions.add(question.id);
      if (answer.isCorrect) scoreCorrect.value++;
    }

    final nextIndex = questions.indexWhere(
      (question) => !_answeredQuestions.contains(question.id),
    );
    if (nextIndex >= 0) {
      currentQuestionIndex.value = nextIndex;
      return;
    }
    currentQuestionIndex.value = questions.length - 1;
    final lastAnswer = byQuestion[questions.last.id]!;
    selectedOptionId.value = lastAnswer.optionId;
    isAnswerCorrect.value = lastAnswer.isCorrect;
    isAnswerChecked.value = true;
  }

  void selectOption(String optionId) {
    if (isAnswerChecked.value || isSubmitting.value) return;
    selectedOptionId.value = optionId;
    submitError.value = '';
  }

  Future<void> checkAnswer() async {
    final optionId = selectedOptionId.value;
    final question = currentQuestion;
    if (_isLeaving ||
        isSubmitting.value ||
        isAnswerChecked.value ||
        optionId == null ||
        question == null ||
        attemptId.isEmpty) {
      return;
    }

    isSubmitting.value = true;
    submitError.value = '';
    try {
      final response = await _repository.submitAnswer(
        attemptId: attemptId,
        questionId: question.id,
        optionId: optionId,
      );
      if (isClosed || _isLeaving) return;
      isAnswerCorrect.value = response.isCorrect;
      correctOptionId.value =
          response.correctOptionId ?? (response.isCorrect ? optionId : null);
      _answeredQuestions.add(question.id);
      if (response.isCorrect) scoreCorrect.value++;
      isAnswerChecked.value = true;
    } catch (e) {
      if (!isClosed && !_isLeaving) {
        submitError.value = _message(
          e,
          'Could not check your answer. Try again.',
        );
      }
    } finally {
      if (!isClosed && !_isLeaving) isSubmitting.value = false;
    }
  }

  void nextQuestion() {
    if (isSubmitting.value || !isAnswerChecked.value || isLastQuestion) return;
    final questions = quiz.value!.questions;
    currentQuestionIndex.value = questions.indexWhere(
      (question) => !_answeredQuestions.contains(question.id),
    );
    selectedOptionId.value = null;
    isAnswerChecked.value = false;
    isAnswerCorrect.value = false;
    correctOptionId.value = null;
    submitError.value = '';
  }

  Future<void> seeResult() async {
    if (_isLeaving ||
        isSubmitting.value ||
        result.value != null ||
        !isLastQuestion ||
        !isAnswerChecked.value ||
        attemptId.isEmpty) {
      return;
    }

    isSubmitting.value = true;
    submitError.value = '';
    try {
      final completed = await _repository.completeAttempt(
        attemptId: attemptId,
        overrideScoreCorrect: scoreCorrect.value,
      );
      if (!isClosed && !_isLeaving) result.value = completed;
    } catch (e) {
      if (!isClosed && !_isLeaving) {
        submitError.value = _message(
          e,
          'Could not save your result. Try again.',
        );
      }
    } finally {
      if (!isClosed && !_isLeaving) isSubmitting.value = false;
    }
  }

  void toggleSpeaker() {
    isTtsSpeaking.value = !isTtsSpeaking.value;
  }

  void playAgain() {
    if (isLoading.value || isSubmitting.value) return;
    loadChapterQuiz();
  }

  Future<void> nextChapter() async {
    if (_isLeaving || isSubmitting.value) return;
    isSubmitting.value = true;
    submitError.value = '';
    try {
      final story = await Get.find<IStoryRepository>().getStoryDetail(storyId);
      if (isClosed || _isLeaving) return;
      final index = story.chapters.indexWhere(
        (chapter) => chapter.id == chapterId,
      );
      if (index < 0 ||
          index + 1 >= story.chapters.length ||
          story.chapters[index + 1].isLocked) {
        backToStory();
        return;
      }
      final next = story.chapters[index + 1];
      _isLeaving = true;
      if (_fromReader) {
        Get.back(result: next.id);
      } else {
        Get.offNamed(
          Routes.STORY_READER,
          arguments: {'storyId': storyId, 'chapterId': next.id},
        );
      }
    } catch (e) {
      if (!isClosed && !_isLeaving) {
        submitError.value = _message(
          e,
          'Could not open the next chapter. Try again.',
        );
      }
    } finally {
      if (!isClosed && !_isLeaving) isSubmitting.value = false;
    }
  }

  void backToStory() {
    if (_isLeaving) return;
    if (storyId.isEmpty) {
      _isLeaving = true;
      HelperUtils.backToMain(tab: 1);
      return;
    }

    _isLeaving = true;
    if (Get.isRegistered<StoriesController>()) {
      final stories = Get.find<StoriesController>();
      stories.selectedDetailTab.value = 1;
      stories.fetchStoryDetail(storyId);
    }
    var found = false;
    Get.until((route) {
      found = route.settings.name == Routes.STORY_DETAILS;
      return found || route.isFirst;
    });
    if (!found) {
      Get.toNamed(Routes.STORY_DETAILS, arguments: {'storyId': storyId});
    }
  }

  String _message(Object error, String fallback) =>
      error is ApiException ? error.message : fallback;

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
      errorMessage.value = _message(
        e,
        'Could not load the checkpoint. Please try again.',
      );
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
