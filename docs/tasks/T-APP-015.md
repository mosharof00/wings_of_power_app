# T-APP-015 — Badges, points, leaderboard, reading progress

**Status:** done

**Depends on:** T-APP-004, T-APP-010

## Scope

`student.badges`, `student.badge_unlocked`, `student.locked_badge`, `student.positive_points`, `student.leaderboard`, `student.reading_progress`.

Skip `design/screens/student/earned_badge/Filter Content Container.png` (junk component crop). The earned state is the badge grid and `Badge Unlocked` / `Badge Unlocked!`.

### Badges

Six badges, in this order when the grid matches the PNG: Kindness Champion, Story Explorer, Helping Hand, Speak Up, Positive Leader, Game Show Ready.

| PNG | What to show |
|-----|----------------|
| `badges_&_achievements/Badges.png` | Partial unlock |
| `badges_&_achievements/Badges & Achievements.png` | Art for the set |
| `badges_&_achievements/Badges & Achievements-1.png` | All locked |
| `profile/Badges & Achievements.png` | Same grid reached from profile. One screen, two entry points |

Earned count vs locks on these frames disagrees. That is already an open question. Each PNG is its own fixture state. Do not “fix” the counts so they agree.

Tap a locked badge → how-to sheet (`How to unlocked.png` through `How to unlocked-5.png`), one sheet per badge, Ok, Got It!

Tap flow for a fresh unlock: `Badge Unlocked.png` (Story Explorer) and `Badge Unlocked!.png` (generic trophy). Actions: Awesome!; View Badge.

Badge tab of the bottom nav opens this grid.

### Points

`profile/Psotive Points.png` (filename typo is the real file): total, today, category rows. Back. `GET /api/student/points` (ledger, paginated, today).

### Leaderboard

`profile/Leaderboard.png`: podium, list, coin scores.

Decision 5 overrides the character figures on that PNG: each row is the student avatar, the student name, and game-edition kindness points. `GET /api/student/leaderboard` with `scope=class|school`. The PNG does not show a class/school switch. Do not add a switch that is not on the frame. Default query `scope=class`.

### Reading progress

`profile/Reading Progress.png`: percent of stories, quiz score, streak, chapter bars, Explore Stories → library.

Mock until `T-BE-014` for badges, `T-BE-011` for points, leaderboard, and reading progress.

Threshold copy on the how-to sheets is the copy printed on each PNG. Do not invent badge math (open question, client item 1).

## Screenshots

- `design/screens/student/badges_&_achievements/Badges.png`
- `design/screens/student/badges_&_achievements/Badges & Achievements.png`
- `design/screens/student/badges_&_achievements/Badges & Achievements-1.png`
- `design/screens/student/profile/Badges & Achievements.png`
- `design/screens/student/badges_&_achievements/Badge Unlocked.png`
- `design/screens/student/badges_&_achievements/Badge Unlocked!.png`
- `design/screens/student/locked_badges/How to unlocked.png`
- `design/screens/student/locked_badges/How to unlocked-1.png`
- `design/screens/student/locked_badges/How to unlocked-2.png`
- `design/screens/student/locked_badges/How to unlocked-3.png`
- `design/screens/student/locked_badges/How to unlocked-4.png`
- `design/screens/student/locked_badges/How to unlocked-5.png`
- `design/screens/student/profile/Psotive Points.png`
- `design/screens/student/profile/Leaderboard.png`
- `design/screens/student/profile/Reading Progress.png`

## Assets

- `assets/badges/badge_kindness_champion.png`
- `assets/badges/badge_story_explorer.png`
- `assets/badges/badge_helping_hand.png`
- `assets/badges/badge_speak_up.png`
- `assets/badges/badge_positive_leader.png`
- `assets/badges/badge_game_show_ready.png`
- `assets/badges/badge_locked.png`
- `assets/icons/ic_nav_badges.svg` already named in `T-APP-004`

## API

Mock until `T-BE-014`:

- `GET /api/badges`
- `GET /api/badges/:id`

Mock until `T-BE-011`:

- `GET /api/student/points`
- `GET /api/student/leaderboard?scope=class`
- `GET /api/student/reading-progress`

## States

- Badges partial, full art, all locked
- Unlock celebration, both PNGs
- Six how-to sheets
- Points history with rows, and empty ledger (shared empty)
- Leaderboard with the current student visible
- Reading progress summary
- Loading and error on each list

## Navigation

- In: badge tab; profile rows for badges, points, leaderboard, progress; quiz complete when a badge was just earned (`T-APP-014`)
- Awesome! dismisses the celebration
- View Badge → that badge on the grid
- Ok, Got It! closes the how-to
- Explore Stories → library (`T-APP-011`)
- Back → profile or the previous tab

## Allowed files

- `lib/app/modules/achievements/**` (new: badges, points, leaderboard, progress)
- `lib/app/data/repositories/achievement_repository.dart` (badges + the three student GETs, or one repository per resource if that stays consistent with `I*Repository`)
- `lib/app/data/models/achievement_models.dart`
- `lib/app/data/mocks/achievements.dart`
- `lib/app/data/repositories/app_repository_binding.dart`
- `lib/app/core/network/api_endpoints.dart`
- `lib/app/modules/main_page/**` (badge tab)
- `lib/app/routes/app_pages.dart`
- `lib/app/routes/app_routes.dart`
- `assets/badges/**`
- This file (Status / Notes)

## Done when

- `flutter analyze` is clean
- `flutter test` passes
- Runs on a simulator
- Each screenshot listed above matches at 375×812
- Leaderboard rows show avatar, name, and kindness points (decision 5)
- `earned_badge/Filter Content Container.png` is not a route
- How-to text matches the six PNGs and does not add thresholds that are not written there

## Notes

- Implemented `BadgesView`, `PositivePointsView`, `LeaderboardView`, and `ReadingProgressView` under `lib/app/modules/achievements/`.
- Wired badges tab in bottom navigation to `BadgesView`.
- Configured routes in `app_pages.dart` and `app_routes.dart` (`Routes.BADGES`, `Routes.POSITIVE_POINTS`, `Routes.LEADERBOARD`, `Routes.READING_PROGRESS`).
- Extracted and bundled 6 badge illustrations plus locked badge art into `assets/badges/`.
- Built How-To-Unlock bottom sheets with exact requirements copy matching the 6 design PNGs without inventing thresholds.
- Built unlock notification dialog (`Awesome!` CTA) and celebration dialog (`View Badge` CTA).
- Built kindness leaderboard according to Decision 5 (student avatar, student name, and kindness points; top 3 podium + scrollable ranked list with current student highlighted).
- Built reading progress summary (60% donut progress, 3 stat tiles, chapter progress bars, Explore Stories CTA -> library).
- Added comprehensive mock fixtures covering partial badges, all locked badges, points history (with empty ledger support), and leaderboard.
- Validation: `flutter analyze` clean (0 issues), `flutter test` passed (10/10 tests).
