import '../config/app_config.dart';

class ApiEndpoint {
  /// Base URL — resolved at call time so platform host (Android/iOS) is correct.
  static String get domainUrl => AppConfig.domainUrl;
  static String get baseUrl => '$domainUrl/api';

  /// Auth
  static String get authBase => '$baseUrl/auth';
  static String get register => '$baseUrl/register'; // post
  static String get login => '$authBase/login'; // post
  static String get studentJoinCode => '$authBase/student/join-code'; // post
  static String get studentCheckUsername =>
      '$authBase/student/check-username'; // get
  static String get studentRegister => '$authBase/student/register'; // post
  static String get studentLogin => '$authBase/student/login'; // post
  static String get me => '$authBase/me'; // get
  static String get logout => '$authBase/logout'; // post
  static String get passwordChange => '$authBase/password'; // patch

  /// Endpoints whose 401 must not trigger the session-expired flow: bad
  /// credentials on login/register, or an already-expired token on logout.
  static List<String> get _credentialPaths => [
        login,
        register,
        logout,
        studentJoinCode,
        studentCheckUsername,
        studentRegister,
        studentLogin,
      ];

  static bool isAuthPath(String? path) =>
      path != null && _credentialPaths.any(path.startsWith);

  /// user profile
  static String get profileDetails => '$baseUrl/profile/details'; // get
  static String get profileUpdate => '$baseUrl/profile/update'; // post

  /// Student Home
  static String get studentHome => '$baseUrl/student/home'; // get

  /// Heroes
  static String get heroes => '$baseUrl/heroes'; // get
  static String heroSelect(String id) => '$baseUrl/heroes/$id/select'; // post

  /// Themes (active book categories)
  static String get themes => '$baseUrl/themes'; // get

  /// Stories
  static String get stories => '$baseUrl/stories'; // get
  static String storyDetail(String id) => '$baseUrl/stories/$id'; // get
  static String storyChapter(String storyId, String chapterId) =>
      '$baseUrl/stories/$storyId/chapters/$chapterId'; // get
  static String storyProgress(String storyId) =>
      '$baseUrl/stories/$storyId/progress'; // put
  static String storyChapterComplete(String storyId, String chapterId) =>
      '$baseUrl/stories/$storyId/chapters/$chapterId/complete'; // post
  static String get pageRead => '$baseUrl/reading/page-read'; // post

  /// Quizzes
  static String chapterQuiz(String chapterId) =>
      '$baseUrl/chapters/$chapterId/quiz'; // get
  static String chapterCheckpoint(String chapterId) =>
      '$baseUrl/chapters/$chapterId/checkpoint'; // get
  static String startQuizAttempt(String quizId) =>
      '$baseUrl/quizzes/$quizId/attempts'; // post
  static String submitAnswer(String attemptId) =>
      '$baseUrl/attempts/$attemptId/answers'; // post
  static String completeAttempt(String attemptId) =>
      '$baseUrl/attempts/$attemptId/complete'; // post

  /// Badges & Achievements
  static String get badges => '$baseUrl/badges'; // get
  static String badgeDetail(String id) => '$baseUrl/badges/$id'; // get

  /// Safe Space Reports
  static String get safeSpaceReports => '$baseUrl/safe-space/reports'; // get, post
  static String safeSpaceReportDetail(String id) =>
      '$baseUrl/safe-space/reports/$id'; // get

  /// Student Points, Leaderboard & Progress
  static String get studentPoints => '$baseUrl/student/points'; // get
  static String studentLeaderboard([String scope = 'class']) =>
      '$baseUrl/student/leaderboard?scope=$scope'; // get
  static String get studentReadingProgress =>
      '$baseUrl/student/reading-progress'; // get

  /// Student Profile & Settings
  static String get studentProfile => '$baseUrl/student/profile'; // get, patch
  static String get studentSettings => '$baseUrl/student/settings'; // get, patch

  /// Game
  static String get gameEligibility => '$baseUrl/game/eligibility'; // get
  static String get gameHowToPlay => '$baseUrl/game/how-to-play'; // get
}
