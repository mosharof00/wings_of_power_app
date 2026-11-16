import 'package:flutter/material.dart';

import 'app_color.dart';

/// Single product UI — sky for app chrome, court purple for game-show.
enum AppBackgroundKind { app, game }

class AppGradients {
  AppGradients._();

  /// Sampled from design `bg` export (top → bottom).
  static const app = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColor.skyTop,
      AppColor.skyMid,
      AppColor.skyBottom,
    ],
    stops: [0.0, 0.55, 1.0],
  );

  /// Basketball game-show screens (mode select / waiting / play shells).
  static const game = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF7822B7),
      Color(0xFF5D1D9B),
      Color(0xFF4C157E),
    ],
  );

  static LinearGradient of(AppBackgroundKind kind) {
    return switch (kind) {
      AppBackgroundKind.app => app,
      AppBackgroundKind.game => game,
    };
  }
}
