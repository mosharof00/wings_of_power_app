import 'package:flutter/material.dart';

class AppColor {
  AppColor._();

  // ── Brand ────────────────────────────────────────────
  /// Primary buttons and the bottom-nav pill. Eyedropped on Login-1, Home-1, Logout, Profile, and Wrong Code.
  static const Color primary = Color(0xFFEE8940);

  /// No disabled control is in the sampled frames. 50% mix of [primary] and white.
  static const Color primaryDisable = Color(0xFFF7C4A0);

  /// Navy titles. Exact on Home.png text rows (“Hey Sarah!”, “Book Categories”).
  static const Color secondary = Color(0xFF2C254B);

  // ── Semantic ─────────────────────────────────────────
  /// Average of red pixels on Wrong Code.png. The sample includes the illustration.
  static const Color error = Color(0xFFB4513C);

  /// Splash wordmark body. Splash Screen.png at (480, 880) on the 2× frame.
  static const Color gold = Color(0xFFFBC841);

  /// Splash wordmark highlight. Splash Screen.png at (240, 880) on the 2× frame.
  static const Color goldHighlight = Color(0xFFF9D05D);

  /// Same gold as [gold]. Kept so older call sites still compile.
  static const Color amber = gold;

  /// Points-chip coin. Home.png at (600, 240) on the 3× frame.
  static const Color coin = Color(0xFF9A6204);

  // ── Light theme surfaces ──────────────────────────────
  /// Sky page background. Splash Screen.png top sample.
  static const Color background = Color(0xFFC4EAFE);

  /// Cream cards, banners, and the logout sheet.
  static const Color cream = Color(0xFFFFF6DE);

  /// Same cream as [cream].
  static const Color background2 = cream;

  static const Color white = Color(0xFFFFFFFF);

  /// Points-chip fill. Home.png samples at (560, 220) and (640, 250).
  static const Color chip = Color(0xFFE9E5F0);

  /// 4pt lip under the login primary button.
  static const Color buttonLip = Color(0xFFC87234);

  // ── Dark theme surfaces ───────────────────────────────
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkBackground2 = Color(0xFF1E1E1E);
  static const Color darkSurface = Color(0xFF2C2C2C);

  // ── Text / Neutral ────────────────────────────────────
  /// Field hint. Login-1.png grey text.
  static const Color hintText = Color(0xFF8A8C92);

  /// Home subtitle “Ready to learn today?” at (400, 300) on the 3× frame.
  static const Color subtitle = Color(0xFF5C5F69);

  /// Same grey as [subtitle].
  static const Color grey410 = subtitle;

  /// Login field edge. Login-1.png at (80, 760) on the 2× frame.
  static const Color inputBorder = Color(0xFFF1F2F2);
}
