# T-APP-002 — Theme and design tokens

**Status:** done

**Depends on:** T-APP-001

## Scope

Replace Quick Cart theme values with tokens measured from the student screenshots. Screenshot checks use a 375×812 logical frame.

In `main.dart`, set `ScreenUtilInit.designSize` to `const Size(375, 812)`.

Set `themeMode` to `ThemeMode.light`. Student frames are light. `AppTheme.dark()` can stay in the file so the boilerplate method still exists; the running app uses light.

Measure from the PNGs (eyedropper on the 1x frame, not from memory):

| Sample | Take from |
|--------|-----------|
| Sky / page background | `design/screens/student/splash_onboarding/Splash Screen.png`, `home/Home.png` |
| Orange primary button and nav pill | `home/Home-1.png` (Start Reading, Play Game, bottom nav) |
| Gold splash wordmark | `splash_onboarding/Splash Screen.png` |
| Navy titles | `home/Home.png` (“Book Categories”), `profile/Profile.png` |
| Input fill, hint, border | `authentication_&_character_choose/Login-1.png` |
| Card fill and border | home story card and profile stat card |
| Error | `authentication_&_character_choose/Wrong Code.png` |
| Points chip | coin chip on `home/Home.png` |

Write the hex values into `AppColor`. Remove the Quick Cart navy `0xFF2E3A83` / `0xFF58619C` as the brand pair once the measured colors replace them.

Radii and shadows, as `AppRadius` and `AppShadow` next to `AppColor` (new file under `lib/app/core/theme/` is fine):

- Primary button
- Search field
- Story / stat card
- Bottom-nav pill
- Points chip
- Sheet top radius (logout sheet `profile/Logout.png`)

Type: the boilerplate uses Poppins via `google_fonts`. Compare that face to titles and body on `Home.png` and `Profile.png`. If Poppins matches, keep it and record that in Notes. If it does not, pick the closest `google_fonts` family, or add a font file under `assets/fonts/` plus a `pubspec.yaml` `fonts:` entry when the face is not on Google Fonts. Map the existing `AppTheme` text slots (display, headline, title, body, label) to the sizes on those screens at 375 width. Keep `text_style_extension.dart` as the way views read styles.

`GlobalButton` and inputs pick up the new color, radius, and shadow in this task only where they already read `AppColor`. Full widget restyle is `T-APP-004`.

## Screenshots

Tokens come from the frames listed above. This task does not build those screens.

## Assets

None. Fonts only if the measured face is not in `google_fonts`.

## API

None.

## States

Light theme only.

## Navigation

None.

## Allowed files

- `lib/main.dart` (`designSize`, `themeMode`)
- `lib/app/core/theme/app_color.dart`
- `lib/app/core/theme/app_theme.dart`
- `lib/app/core/theme/app_radius.dart` (new)
- `lib/app/core/theme/app_shadow.dart` (new)
- `lib/app/core/extensions/text_style_extension.dart` (only if a text slot must be added)
- `pubspec.yaml` and `assets/fonts/**` only if a bundled font is required
- This file (Status / Notes)

## Done when

- `flutter analyze` is clean
- `flutter test` passes
- App runs on a simulator in light theme
- `designSize` is 375×812
- `AppColor` no longer uses the Quick Cart navy pair as primary/secondary
- Notes list the measured hex values, radii, and the font family chosen

## Notes

- `flutter analyze`: no issues. `flutter test`: passed. iPhone 18 Pro Max simulator launched in light theme; after the white splash the blank login scaffold is the sky background.
- `ScreenUtilInit.designSize` is `Size(375, 812)`. `themeMode` is `ThemeMode.light`. `AppTheme.dark()` is still in the file and is not selected at runtime.
- Font is Nunito via `google_fonts`. Poppins terminals are flat; Home.png titles (“Hey Sarah!”, “Book Categories”) are rounded. No bundled font. Largest type on Home.png and Profile.png is 18pt (greeting and section titles, w700). Profile name is 14pt (28px at 2×). Subtitle “Ready to learn today?” is ~13pt (40px at 3×). Those three sizes are the text slots. `text_style_extension.dart` was not edited (no new slot); its comments still say Poppins. `dialog_utils.dart` still calls `GoogleFonts.poppins` and is outside this task’s allowed files — T-APP-004 should switch dialogs to the theme.
- Colors (eyedropped unless noted):
  - Primary `#EE8940` (buttons and nav)
  - Navy titles `#2C254B` (`AppColor.secondary`)
  - Sky background `#C4EAFE`
  - Cream cards / sheet `#FFF6DE` (`cream`, `background2`)
  - White `#FFFFFF` (inputs, inner cells)
  - Points chip `#E9E5F0`
  - Coin `#9A6204`
  - Wordmark gold `#FBC841`, highlight `#F9D05D`
  - Subtitle `#5C5F69`
  - Hint `#8A8C92`
  - Input edge `#F1F2F2`
  - Button lip `#C87234`
  - Error `#B4513C` — average of red pixels on Wrong Code.png, including the illustration
  - `primaryDisable` `#F7C4A0` — derived, 50% mix of `#EE8940` and white. No disabled control was in the frames.
- Quick Cart navy `0xFF2E3A83` / `0xFF58619C` is gone.
- Radii are design points. Capsules use half the control height:
  - Full-width button 22 (44pt tall)
  - Compact home button 16 (32pt tall)
  - Search 17 (~34pt tall)
  - Stat card 14
  - Bottom nav 32 (64pt tall)
  - Points chip 10 (~19pt tall)
  - Logout sheet top 26
- Shadows: primary button is a hard 4pt lip, offset `(0, 4)`, blur 0, color `#C87234`. Search, card, nav, chip, and sheet have no separate drop shadow in the samples (`AppShadow` lists are empty).
- `GlobalButton` picks up the new primary through `AppColor`. Its 12 radius stays until T-APP-004.
