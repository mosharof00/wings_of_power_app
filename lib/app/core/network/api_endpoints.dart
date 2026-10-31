import '../config/app_config.dart';

class ApiEndpoint {
  ///  Base URL
  static const String domainUrl = AppConfig.domainUrl;
  static const String baseUrl = '$domainUrl/api';

  ///  Auth
  static const String authBase = '$baseUrl/auth';
  static const String register = '$baseUrl/register'; // post
  static const String login = '$authBase/login'; // post
  static const String me = '$authBase/me'; // get
  static const String logout = '$authBase/logout'; // post

  /// Endpoints whose 401 must not trigger the session-expired flow: bad
  /// credentials on login/register, or an already-expired token on logout.
  static const List<String> _credentialPaths = [login, register, logout];

  static bool isAuthPath(String? path) =>
      path != null && _credentialPaths.any(path.startsWith);

  /// user profile
  static const String profileDetails = '$baseUrl/profile/details'; // get
  static const String profileUpdate = '$baseUrl/profile/update'; // post
}
