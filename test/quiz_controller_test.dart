import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/network/api_exception.dart';
import 'package:wings_of_power_app/app/core/theme/app_theme.dart';
import 'package:wings_of_power_app/app/data/models/quiz_models.dart';
import 'package:wings_of_power_app/app/data/repositories/quiz_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/story_repository.dart';
import 'package:wings_of_power_app/app/global/widgets/app_sunburst_background.dart';
import 'package:wings_of_power_app/app/modules/quiz/bindings/quiz_binding.dart';
import 'package:wings_of_power_app/app/modules/quiz/controllers/quiz_controller.dart';
import 'package:wings_of_power_app/app/modules/quiz/views/chapter_quiz_view.dart';
import 'package:wings_of_power_app/app/modules/reader/controllers/reader_controller.dart';
import 'package:wings_of_power_app/app/modules/reader/views/widgets/reader_completed_view.dart';
import 'package:wings_of_power_app/app/routes/app_pages.dart';

void main() {
  test('resumes an answered chapter quiz and uses the saved result', () async {
    final repository = _QuizRepository();
    final controller = QuizController(repository)..chapterId = 'live-chapter';

    await controller.loadChapterQuiz();
    expect(repository.requestedChapter, 'live-chapter');
    expect(controller.currentQuestion?.id, 'second');
    expect(controller.scoreCorrect.value, 1);

    controller.selectOption('option');
    await controller.checkAnswer();
    await controller.seeResult();

    expect(controller.result.value?.scoreCorrect, 1);
    expect(controller.result.value?.scoreTotal, 2);
    expect(controller.result.value?.pointsAwarded, 0);
    expect(repository.submittedQuestions, ['second']);
  });

  test('treats a missing chapter quiz as unavailable', () async {
    final repository = _QuizRepository()..missingQuiz = true;
    final controller = QuizController(repository)..chapterId = 'live-chapter';

    await controller.loadChapterQuiz();

    expect(controller.isQuizUnavailable.value, isTrue);
    expect(controller.isError.value, isFalse);
    expect(repository.startedAttempts, 0);
  });

  testWidgets('the completed reader opens an empty quiz without crashing', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() => Get.reset());
    final repository = _QuizRepository()..emptyQuiz = true;
    Get.put<IQuizRepository>(repository, permanent: true);
    final reader = ReaderController(_UnusedStoryRepository())
      ..storyId = 'story'
      ..chapterId = 'live-chapter';

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => GetMaterialApp(
          theme: AppTheme.light(),
          initialRoute: Routes.STORY_DETAILS,
          getPages: [
            GetPage(
              name: Routes.STORY_DETAILS,
              page: () => ReaderCompletedView(controller: reader),
            ),
            GetPage(
              name: Routes.CHAPTER_QUIZ,
              page: () => const ChapterQuizView(),
              binding: QuizBinding(),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take Quiz Now!'));
    await tester.pumpAndSettle();

    expect(find.text('No quiz yet'), findsOneWidget);
    expect(find.text('Something went wrong'), findsNothing);
    expect(repository.requestedChapter, 'live-chapter');
    expect(repository.startedAttempts, 0);
    await tester.tap(find.text('Back to Story'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, Routes.STORY_DETAILS);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long answers fit and retake returns to the original story', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() => Get.reset());
    final repository = _QuizRepository();
    Get.put<IQuizRepository>(repository, permanent: true);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => GetMaterialApp(
          theme: AppTheme.light(),
          initialRoute: Routes.MAIN_PAGE,
          getPages: [
            GetPage(
              name: Routes.MAIN_PAGE,
              page: () => Scaffold(
                body: TextButton(
                  onPressed: () => Get.toNamed(Routes.STORY_DETAILS),
                  child: const Text('Open story'),
                ),
              ),
            ),
            GetPage(
              name: Routes.STORY_DETAILS,
              page: () => Scaffold(
                body: TextButton(
                  onPressed: () => Get.toNamed(
                    Routes.CHAPTER_QUIZ,
                    arguments: {
                      'storyId': 'story',
                      'chapterId': 'live-chapter',
                    },
                  ),
                  child: const Text('Open quiz'),
                ),
              ),
            ),
            GetPage(
              name: Routes.CHAPTER_QUIZ,
              page: () => const ChapterQuizView(),
              binding: QuizBinding(),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open story'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open quiz'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(_longAnswer));
    await tester.tap(find.text(_longAnswer));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Check Answer'));
    await tester.tap(find.text('Check Answer'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('See Result'));
    await tester.tap(find.text('See Result'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(AppSunburstBackground), findsOneWidget);
    expect(find.text('Quiz Score'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('+0 Points'), findsOneWidget);
    await tester.ensureVisible(find.text('Play Again!'));
    await tester.tap(find.text('Play Again!'));
    await tester.pumpAndSettle();
    expect(find.text('First?'), findsOneWidget);

    Get.find<QuizController>().backToStory();
    await tester.pumpAndSettle();
    expect(find.text('Open quiz'), findsOneWidget);
    expect(Get.isRegistered<QuizController>(), isFalse);
    Get.back();
    await tester.pumpAndSettle();
    expect(find.text('Open story'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

const _longAnswer =
    'He saw the tortoise was already near the finishing line after slowly '
    'crossing the bridge in front of the other animals.';

class _QuizRepository implements IQuizRepository {
  String? requestedChapter;
  bool missingQuiz = false;
  bool emptyQuiz = false;
  int startedAttempts = 0;
  final submittedQuestions = <String>[];

  @override
  Future<QuizModel> getChapterQuiz(String chapterId) async {
    requestedChapter = chapterId;
    if (missingQuiz) throw ApiException('Quiz not found', statusCode: 404);
    return QuizModel(
      id: 'quiz',
      chapterId: chapterId,
      questions: emptyQuiz
          ? const []
          : const [
              QuizQuestionModel(
                id: 'first',
                sortOrder: 0,
                prompt: 'First?',
                options: [],
              ),
              QuizQuestionModel(
                id: 'second',
                sortOrder: 1,
                prompt: 'Second?',
                options: [
                  QuizOptionModel(
                    id: 'option',
                    sortOrder: 0,
                    label: _longAnswer,
                  ),
                  QuizOptionModel(
                    id: 'other',
                    sortOrder: 1,
                    label: 'Another answer',
                  ),
                ],
              ),
            ],
    );
  }

  @override
  Future<QuizAttemptModel> startQuizAttempt(String quizId) async =>
      QuizAttemptModel.fromJson({
        'id': 'attempt-${++startedAttempts}',
        'quizId': quizId,
        'answers': [
          if (startedAttempts == 1)
            {'questionId': 'first', 'optionId': 'saved', 'isCorrect': true},
        ],
      });

  @override
  Future<SubmitAnswerResponseModel> submitAnswer({
    required String attemptId,
    required String questionId,
    String? optionId,
    String? freeText,
  }) async {
    submittedQuestions.add(questionId);
    return SubmitAnswerResponseModel(
      id: 'answer',
      attemptId: attemptId,
      questionId: questionId,
      isCorrect: false,
    );
  }

  @override
  Future<CompleteAttemptResponseModel> completeAttempt({
    required String attemptId,
    int? overrideScoreCorrect,
  }) async => CompleteAttemptResponseModel(
    id: attemptId,
    quizId: 'quiz',
    scoreCorrect: 1,
    scoreTotal: 2,
    pointsAwarded: 0,
  );

  @override
  Future<QuizModel> getChapterCheckpoint(String chapterId) =>
      throw UnimplementedError();
}

class _UnusedStoryRepository implements IStoryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
