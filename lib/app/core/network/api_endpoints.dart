import '../config/app_config.dart';

class ApiEndpoint {
  ///  Base URL
  static const String domainUrl = AppConfig.domainUrl;
  static const String baseUrl = '$domainUrl/api';

  ///  Auth
  static const String authBase = '$baseUrl/auth';
  static const String register = '$baseUrl/register'; // post
  static const String login = '$authBase/login'; // post
  static const String studentJoinCode = '$authBase/student/join-code'; // post
  static const String studentRegister = '$authBase/student/register'; // post
  static const String studentLogin = '$authBase/student/login'; // post
  static const String me = '$authBase/me'; // get
  static const String logout = '$authBase/logout'; // post

  /// Endpoints whose 401 must not trigger the session-expired flow: bad
  /// credentials on login/register, or an already-expired token on logout.
  static const List<String> _credentialPaths = [
    login,
    register,
    logout,
    studentJoinCode,
    studentRegister,
    studentLogin,
  ];

  static bool isAuthPath(String? path) =>
      path != null && _credentialPaths.any(path.startsWith);

  /// user profile
  static const String profileDetails = '$baseUrl/profile/details'; // get
  static const String profileUpdate = '$baseUrl/profile/update'; // post

  /// Student Home
  static const String studentHome = '$baseUrl/student/home'; // get

  /// Heroes
  static const String heroes = '$baseUrl/heroes'; // get
  static String heroSelect(String id) => '$baseUrl/heroes/$id/select'; // post

  /// Stories
  static const String stories = '$baseUrl/stories'; // get
  static String storyDetail(String id) => '$baseUrl/stories/$id'; // get
  static String storyChapter(String storyId, String chapterId) =>
      '$baseUrl/stories/$storyId/chapters/$chapterId'; // get
  static String storyProgress(String storyId) =>
      '$baseUrl/stories/$storyId/progress'; // put
  static String storyChapterComplete(String storyId, String chapterId) =>
      '$baseUrl/stories/$storyId/chapters/$chapterId/complete'; // post
}
