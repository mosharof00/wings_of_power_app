import 'package:flutter/material.dart';

import 'app_color.dart';

/// Shadows in design points on the 375×812 frame.
///
/// Only the primary button has a sampled shadow. The other lists are empty
/// because those edges sit on the sky or cream with no separate drop shadow.
class AppShadow {
  AppShadow._();

  /// Hard 4pt lip. Login-1.png, the band directly under the orange button.
  static const List<BoxShadow> button = [
    BoxShadow(
      color: AppColor.buttonLip,
      offset: Offset(0, 4),
      blurRadius: 0,
    ),
  ];

  static const List<BoxShadow> search = [];

  static const List<BoxShadow> card = [];

  static const List<BoxShadow> nav = [];

  static const List<BoxShadow> chip = [];

  static const List<BoxShadow> sheet = [];
}
