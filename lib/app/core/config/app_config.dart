import '../../../gen/assets.gen.dart';

class AppConfig {
  /// Logo
  static String get appLogo => Assets.logos.appIcon.path;
  static String get splashLogo => Assets.logos.appIcon.path;
  static String appName = "Wings of Power";

  /// Host is unset. Repositories must not call the network while [useMocks] is true.
  static const domainUrl = "http://localhost";

  /// When true, repositories return fixtures and do not call the network.
  static const bool useMocks = true;

  /// true: guests are sent to login from the splash.
  /// false: guests can open the main page.
  static const bool requireLogin = true;
}
