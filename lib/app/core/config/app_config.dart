import '../../../gen/assets.gen.dart';

class AppConfig {
  /// Logo
  static String appLogo = "assets/logos/app_icon.png";
  static String splashLogo = "assets/logos/app_icon.png";
  static String appName = "Quick Cart";
  static const domainUrl = "https://flutter.pixelstack.cloud";

  /// true: guests are sent to login from the splash.
  /// false: guests can browse the main page (use `showAuthDialog` to gate
  /// protected actions).
  static const bool requireLogin = true;

  /// ProjectID
  static String projectID = "vendex-user-app";

  //Push Notification key

}
