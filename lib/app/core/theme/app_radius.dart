/// Corner radii in design points on the 375×812 frame.
///
/// Capsules use half the control height. Widgets apply these with ScreenUtil.
class AppRadius {
  AppRadius._();

  /// Full-width primary CTA. Login-1.png button is 88px tall at 2× (44pt).
  static const double button = 22;

  /// Home Start Reading / Play Game. 96px tall at 3× (32pt).
  static const double buttonCompact = 16;

  /// Home search. A white column at x=400 spans 103px at 3× (~34pt).
  static const double search = 17;

  /// Profile stat card. Cream corner reaches the side 28px below the top at 2×.
  static const double card = 14;

  /// Bottom-nav pill. The solid column on Home-1.png is 192px tall at 3× (64pt).
  static const double nav = 32;

  /// Points chip. Lavender body on Home.png is 58px tall at 3× (~19pt).
  static const double chip = 10;

  /// Logout sheet top corner. The curve is 52px tall at 2×.
  static const double sheet = 26;
}
