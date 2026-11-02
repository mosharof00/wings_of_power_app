import 'package:wings_of_power_app/app/core/config/app_config.dart';
import 'package:wings_of_power_app/app/core/network/api_client.dart';
import 'package:wings_of_power_app/app/core/network/api_endpoints.dart';
import '../mocks/quizzes.dart';
import '../models/quiz_models.dart';

abstract class IQuizRepository {
  Future<QuizModel> getChapterQuiz(String chapterId);
  Future<QuizModel> getChapterCheckpoint(String chapterId);
  Future<QuizAttemptModel> startQuizAttempt(String quizId);
  Future<SubmitAnswerResponseModel> submitAnswer({
    required String attemptId,
    required String questionId,
    String? optionId,
    String? freeText,
  });
  Future<CompleteAttemptResponseModel> completeAttempt({
    required String attemptId,
    int? overrideScoreCorrect,
  });
}

class QuizRepository implements IQuizRepository {
  final ApiClient _client;

  QuizRepository(this._client);

  @override
  Future<QuizModel> getChapterQuiz(String chapterId) async {
    if (AppConfig.useMocks) {
      return QuizzesMock.getChapterQuiz(chapterId);
    }
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.chapterQuiz(chapterId)),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map<String, dynamic>
            : (data is Map ? data as Map<String, dynamic> : <String, dynamic>{});
        return QuizModel.fromJson(map);
      },
      'Get Chapter Quiz',
    );
  }

  @override
  Future<QuizModel> getChapterCheckpoint(String chapterId) async {
    if (AppConfig.useMocks) {
      return QuizzesMock.getChapterCheckpoint(chapterId);
    }
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.chapterCheckpoint(chapterId)),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map<String, dynamic>
            : (data is Map ? data as Map<String, dynamic> : <String, dynamic>{});
        return QuizModel.fromJson(map);
      },
      'Get Chapter Checkpoint',
    );
  }

  @override
  Future<QuizAttemptModel> startQuizAttempt(String quizId) async {
    if (AppConfig.useMocks) {
      return QuizzesMock.startQuizAttempt(quizId);
    }
    return _client.handleRequest(
      () => _client.dio.post(ApiEndpoint.startQuizAttempt(quizId)),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map<String, dynamic>
            : (data is Map ? data as Map<String, dynamic> : <String, dynamic>{});
        return QuizAttemptModel.fromJson(map);
      },
      'Start Quiz Attempt',
    );
  }

  @override
  Future<SubmitAnswerResponseModel> submitAnswer({
    required String attemptId,
    required String questionId,
    String? optionId,
    String? freeText,
  }) async {
    if (AppConfig.useMocks) {
      return QuizzesMock.submitAnswer(
        attemptId: attemptId,
        questionId: questionId,
        optionId: optionId,
        freeText: freeText,
      );
    }
    return _client.handleRequest(
      () => _client.dio.post(
        ApiEndpoint.submitAnswer(attemptId),
        data: {
          'questionId': questionId,
          'optionId': ?optionId,
          'freeText': ?freeText,
        },
      ),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map<String, dynamic>
            : (data is Map ? data as Map<String, dynamic> : <String, dynamic>{});
        return SubmitAnswerResponseModel.fromJson(map);
      },
      'Submit Quiz Answer',
    );
  }

  @override
  Future<CompleteAttemptResponseModel> completeAttempt({
    required String attemptId,
    int? overrideScoreCorrect,
  }) async {
    if (AppConfig.useMocks) {
      return QuizzesMock.completeAttempt(
        attemptId: attemptId,
        overrideScoreCorrect: overrideScoreCorrect,
      );
    }
    return _client.handleRequest(
      () => _client.dio.post(ApiEndpoint.completeAttempt(attemptId)),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map<String, dynamic>
            : (data is Map ? data as Map<String, dynamic> : <String, dynamic>{});
        return CompleteAttemptResponseModel.fromJson(map);
      },
      'Complete Quiz Attempt',
    );
  }
}
