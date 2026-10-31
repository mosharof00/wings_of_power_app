class AppConfig {
  /// Logo
  static String appLogo = "assets/logos/app_icon.png";
  static String splashLogo = "assets/logos/app_icon.png";
  static String appName = "Wings of Power";

  /// Host is unset. Repositories must not call the network while [useMocks] is true.
  static const domainUrl = "http://localhost";

  /// When true, repositories return fixtures and do not call the network.
  static const bool useMocks = true;

  /// true: guests are sent to login from the splash.
  /// false: guests can open the main page.
  static const bool requireLogin = true;
}
