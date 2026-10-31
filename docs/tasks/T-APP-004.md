# T-APP-004 — Shared widgets

**Status:** done

**Depends on:** T-APP-002, T-APP-003

## Scope

Build the widgets that two or more student screens share. Restyle the boilerplate widgets that already cover the job. Do not add a second button or dialog system beside them.

| Widget | Build on | Used by |
|--------|----------|---------|
| Primary button (orange pill) | `GlobalButton` | Welcome, join, login, setup, quizzes, Safe Space, profile save |
| Secondary / text button | `GlobalButton` variant | Welcome’s second action, quiz “Back to Story”, sheets |
| Text field + password field | `AppInputTextFormField`, existing `PasswordInputField` | Login, credentials, nickname, real name, search, report, change password |
| Search field | text field + filter icon slot | Home, story library |
| Points chip (coin + count) | new, in `lib/app/global/widgets/` | Home header, profile stat, points history, quiz result, leaderboard |
| Story card | new | Home “Popular Stories”, library grid |
| Category card | new | Home categories, library categories |
| Linear progress | new | Chapter rows, reading progress, quiz result bar |
| Step / star progress | new | Onboarding dots, chapter-quiz stars |
| Bottom nav | new shell chrome. Remove any leftover `google_nav_bar` use | Home, library, badges, profile |
| Back circle | new or `custom_icon_button.dart` | Every pushed screen that shows the orange back circle |
| Sheet / confirm dialog | `custom_dialog.dart` / `DialogUtils`, restyled to the cream sheets | Logout, leave quiz, hero confirm, locked-badge how-to, how the app works, report detail |
| Loading | `global_loading.dart` + shimmer | Library `Loading State.png`, reader `Loading State.png`, list fetches |
| Empty | `show_empty_result.dart` | Library, reports, points history |
| Error | new banner or full-page block for a failed fetch | Any repository error. Wrong-code and expired-code are full screens in `T-APP-006`, not this widget |

Bottom nav (`Home.png`, `Home-1.png`, `Profile.png`): orange pill, five icons, no labels — home, book, basketball, badge, person.

- Home, book, badge, person change the selected tab (`MainPageController` or its replacement).
- Basketball is visible so the bar matches the screenshot. The tap does not open `design/screens/game/**`. Leave the handler empty and name the game plan in a short comment.
- Icons come from `assets/icons/` via `Assets.icons`. If the SVG is not exported yet, add a named placeholder SVG in that folder (`ic_nav_home.svg`, `ic_nav_stories.svg`, `ic_nav_game.svg`, `ic_nav_badges.svg`, `ic_nav_profile.svg`) using the token colors. Replace the file when real art arrives; do not change the getter name.

`awesome_dialog` may stay if `DialogUtils` still wraps it and the sheet matches `profile/Logout.png` (title, body, two buttons, top radius from `AppRadius`). If the package cannot match that sheet, replace the call with the restyled `custom_dialog.dart` and drop `awesome_dialog` in this task.

This task does not build feature screens. A widget gallery is optional and must not add a route that ships in the student flow. Prefer a widget test per new widget over a gallery route.

## Screenshots

Match pieces, not whole flows:

- `design/screens/student/home/Home.png` — chip, search, cards, nav
- `design/screens/student/home/Home-1.png` — primary button, nav
- `design/screens/student/profile/Logout.png` — sheet
- `design/screens/student/story_description_&_chapters/new_student/Loading State.png` — loading
- `design/screens/student/authentication_&_character_choose/Login-1.png` — field
- `design/screens/student/splash_onboarding/Onboarding1.png` — page dots

## Assets

`assets/icons/ic_nav_home.svg`, `ic_nav_stories.svg`, `ic_nav_game.svg`, `ic_nav_badges.svg`, `ic_nav_profile.svg`, plus a coin mark `ic_points_coin.svg` if the export has no coin. Regenerate `Assets` the way `T-APP-003` describes.

## API

None.

## States

- Button enabled, disabled, loading
- Field empty, filled, error text, password hidden / shown
- Progress at 0 and at a partial value
- Nav home selected and profile selected (the two frames above)
- Loading, empty, and error blocks

## Navigation

The nav widget calls the shell controller. Tab pages themselves are later tasks. Until those views exist, each tab can show a titled blank page so the shell runs.

## Allowed files

- `lib/app/global/widgets/**`
- `lib/app/global/layouts/**` (no product layout)
- `lib/app/core/utils/dialog_utils.dart`
- `lib/app/modules/main_page/**`
- `lib/app/routes/app_pages.dart` and `app_routes.dart` only if a tab route constant is required for the shell
- `assets/icons/ic_nav_*.svg`, `assets/icons/ic_points_coin.svg`
- `pubspec.yaml` only to remove `awesome_dialog` if the sheet no longer uses it
- `test/**` widget tests for the new widgets
- This file (Status / Notes)

## Done when

- `flutter analyze` is clean
- `flutter test` passes
- App runs on a simulator with the five-icon nav at 375×812, home and profile selection matching the PNGs listed above
- Basketball tab does not open a game route
- No second button, field, or dialog widget parallel to the ones named above

## Notes

- `GlobalButton` is the only button. `primary` is the orange pill (44pt, radius `AppRadius.button`, 4pt lip). `secondary` is the white pill with orange text from Logout.png. `text` is an orange label with no fill. `isDisabled` and `isLoading` block the tap.
- Fields stay on `AppInputTextFormField` and `PasswordInputField`. Default field is a white pill with an orange border, matching Login-1.png. `SearchField` is that field with a search icon and a filter slot, borderless, radius `AppRadius.search`.
- New widgets in `lib/app/global/widgets/`: `PointsChip`, `StoryCard`, `CategoryCard`, `LinearProgressBar`, `StepProgress` (dots and stars), `StudentBottomNav`, `SearchField`, `ErrorBlock`. `LoadingCard` sits next to `GlobalLoading`. Wrong-code and expired-code screens are not this error widget.
- `CustomIconButton` defaults to the orange back circle and a white arrow.
- Confirm UI is a cream bottom sheet (`CustomDialog` + `DialogUtils`): handle, title, body, primary button, optional secondary button, top radius `AppRadius.sheet`. `awesome_dialog` stays in `pubspec.yaml` because `helper_utils.dart` (outside this task) still passes `DialogType`. The sheet does not use `AwesomeDialog`.
- Bottom nav is an orange pill, five icons, no labels. Home, stories, badges, and profile change `MainPageController.selectedIndex`. Basketball calls `onNavTap` and returns without a route (`T-GAME-001`). Placeholder SVGs: `ic_nav_home`, `ic_nav_stories`, `ic_nav_game`, `ic_nav_badges`, `ic_nav_profile`, `ic_points_coin`. Replace the files later; the getters stay. `Assets` was regenerated.
- The shell shows `HomeView` on the home tab. Stories, badges, and profile are titled blank pages until those screens exist. Profile is not `ProfileView` yet, because that view needs a controller this binding does not create.
- `flutter analyze`: no issues. `flutter test`: passed, including home selected, profile selected, and the basketball tap leaving the tab unchanged. The shell was also rendered at 375×812: home shows the white circle on the house, profile moves that circle to the person, and a basketball tap does not move it. A guest launch on the iPhone 18 Pro Max still stops on the blank login screen, because login is required and that screen is a later task.
