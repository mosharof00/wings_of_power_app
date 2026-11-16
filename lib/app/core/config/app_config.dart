import 'package:flutter/foundation.dart';

import '../../../gen/assets.gen.dart';

class AppConfig {
  /// Logo
  static String get appLogo => Assets.logos.appIcon.path;
  static String get splashLogo => Assets.logos.appIcon.path;
  static String appName = "Wings of Power";

  /// Nest API origin (no `/api` suffix — [ApiEndpoint] adds it).
  ///
  /// - Android emulator → host machine via `10.0.2.2`
  /// - iOS simulator / desktop → `127.0.0.1`
  /// - Physical device → set [lanHost] to your Mac LAN IP (e.g. `10.10.18.34`)
  static const String? lanHost = null;

  static String get domainUrl {
    if (lanHost != null && lanHost!.isNotEmpty) {
      return 'http://$lanHost:6001';
    }
    if (kIsWeb) return 'http://127.0.0.1:6001';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:6001';
      default:
        return 'http://127.0.0.1:6001';
    }
  }

  /// When true, repositories return fixtures and do not call the network.
  static const bool useMocks = false;

  /// true: guests are sent to login from the splash.
  /// false: guests can open the main page.
  static const bool requireLogin = true;
}
