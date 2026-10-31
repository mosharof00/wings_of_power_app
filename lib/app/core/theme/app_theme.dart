import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColor.background,
      textTheme: _buildTextTheme(AppColor.secondary),
      colorScheme: ColorScheme.light(
        primary: AppColor.primary,
        secondary: AppColor.secondary,
        error: AppColor.error,
        surface: AppColor.white,
        onPrimary: AppColor.white,
        onSecondary: AppColor.white,
        onSurface: AppColor.secondary,
        onError: AppColor.white,
      ),
      appBarTheme: AppBarTheme(
        titleTextStyle: _font(18.sp, FontWeight.w700, AppColor.secondary),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColor.background,
        foregroundColor: AppColor.secondary,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColor.darkBackground,
      textTheme: _buildTextTheme(AppColor.white),
      colorScheme: ColorScheme.dark(
        primary: AppColor.primary,
        secondary: AppColor.secondary,
        error: AppColor.error,
        surface: AppColor.darkSurface,
        onPrimary: AppColor.white,
        onSecondary: AppColor.white,
        onSurface: AppColor.white,
        onError: AppColor.white,
      ),
      appBarTheme: AppBarTheme(
        titleTextStyle: _font(18.sp, FontWeight.w600, AppColor.white),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColor.darkBackground2,
        foregroundColor: AppColor.white,
      ),
    );
  }

  static TextStyle _font(double size, FontWeight weight, Color color) {
    return GoogleFonts.nunito(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static TextTheme _buildTextTheme(Color baseColor) {
    return TextTheme(
      // Largest type on Home.png and Profile.png is 18pt (greeting and section titles).
      displayLarge: _font(18.sp, FontWeight.w700, baseColor),
      displayMedium: _font(18.sp, FontWeight.w700, baseColor),
      headlineLarge: _font(18.sp, FontWeight.w700, baseColor),
      headlineMedium: _font(18.sp, FontWeight.w700, baseColor),
      // Profile name “Sarah” is 28px at 2×.
      titleLarge: _font(14.sp, FontWeight.w700, baseColor),
      titleMedium: _font(14.sp, FontWeight.w700, baseColor),
      titleSmall: _font(14.sp, FontWeight.w600, baseColor),
      bodyLarge: _font(14.sp, FontWeight.w500, baseColor),
      // “Ready to learn today?” glyph box is 40px at 3× (~13pt).
      bodyMedium: _font(13.sp, FontWeight.w500, baseColor),
      bodySmall: _font(13.sp, FontWeight.w400, baseColor),
      labelLarge: _font(14.sp, FontWeight.w600, baseColor),
      labelSmall: _font(13.sp, FontWeight.w600, baseColor),
    );
  }
}
