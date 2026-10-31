# T-APP-017 — Profile and settings

**Status:** todo

**Depends on:** T-APP-004, T-APP-009, T-APP-015, T-APP-016

Rows that leave this module depend on those tasks. The hub can be built against their routes once the routes exist.

## Scope

`student.profile`, `student.settings`, `student.edit_profile`, `student.change_password`, `student.logout_confirm`, `student.how_app_works`.

Profile hub (`Profile.png`):

- Avatar, name Sarah, the two lines under the name as laid out on the PNG (“4 years old” and “Grade A, Ms. Smith Class”)
- Age vs grade on that frame conflicts (inventory). Show both lines in the layout. Bind the class line to class name from `GET /api/student/profile` / `GET /api/auth/me`. The age line has no field in `docs/API.md`. The mock fixture uses the PNG’s “4 years old” so the frame can be checked. Do not add an age endpoint and do not compute age
- Stat cards: Points 245, Badges 3, Progress 30% in the fixture — each opens `T-APP-015`
- Menu: My Power Hero, My Reading Progress, Badges & Achievements, Positive Points, Leaderboard, My Reports, Notifications
- Gear → settings
- Person tab selects this hub
- Notifications row is drawn. It has no screen (D14). The tap does nothing

Settings (`Settings.png`):

| Control | Behavior |
|---------|----------|
| Read to Me | `GET/PATCH /api/student/settings` |
| Sound Effect | same |
| Notifications: Stories, Badges & Achievements, Game Show, Safe Space Activity | same `settings_json` |
| Change Password | `T-APP-017` form |
| Log Out | logout sheet |
| I Need Help | Safe Space intro (`T-APP-016`, decision 9) |
| How the App Work | local sheet, no API |

Edit profile: face avatars (not power heroes), name, class read-only, Save Changes. `PATCH /api/student/profile` with `nickname` and `avatarUrl`. Class is not editable. `image_picker` is already a dependency if the PNG’s faces are a preset row rather than the camera; use the preset faces on `Edit Profile.png`. Do not add a camera flow that is not on that PNG.

Change password: current, new, confirm. `PATCH /api/auth/password` `{ current, next }`.

Logout sheet: “Leaving Already?”, Stay, Log out. Log out calls `POST /api/auth/logout`, clears the secure token, and `Get.offAllNamed` welcome.

How the app works sheet: read/listen, game show, safe space, Got It. Client-only.

Mock until `T-BE-011` for profile and settings, `T-BE-010` for password and logout.

## Screenshots

- `design/screens/student/profile/Profile.png`
- `design/screens/student/profile/Settings.png`
- `design/screens/student/profile/Edit Profile.png`
- `design/screens/student/profile/Change Password.png`
- `design/screens/student/profile/Logout.png`
- `design/screens/student/profile/How the app work.png`

These profile PNGs belong to other tasks: `Power Hero.png` (`T-APP-009`), `Badges & Achievements.png`, `Psotive Points.png`, `Leaderboard.png`, `Reading Progress.png` (`T-APP-015`), `My Reports.png` (`T-APP-016`).

## Assets

- `assets/images/avatar_1.png` … preset faces shown on Edit Profile (name them `avatar_01.png` upward in the order on the PNG)
- `assets/icons/ic_settings.svg`
- Row icons can be the SVG set `assets/icons/ic_profile_hero.svg`, `ic_profile_progress.svg`, `ic_profile_badges.svg`, `ic_profile_points.svg`, `ic_profile_leaderboard.svg`, `ic_profile_reports.svg`, `ic_profile_notifications.svg`

## API

Mock until `T-BE-011`:

- `GET /api/student/profile`
- `PATCH /api/student/profile` — `nickname`, `avatarUrl`
- `GET /api/student/settings`
- `PATCH /api/student/settings`

Mock until `T-BE-010`:

- `PATCH /api/auth/password` — `current`, `next`
- `POST /api/auth/logout`

How the app works: no API.

## States

- Profile hub with the three stats and seven rows
- Settings with each toggle on (the PNG shows them on) and one toggle turned off
- Edit profile, class field not editable, Save Changes
- Change password empty, mismatch, success
- Logout sheet
- How the app works sheet
- 400 on change password stays on the form

## Navigation

- In: person tab
- Gear → settings
- Back on settings → profile
- Stat cards and the first six menu rows → the tasks named in `docs/PLAN.md`
- Notifications → stay on profile
- Edit entry is the avatar / name control on `Edit Profile.png` (open that PNG and use the control it shows)
- Change Password → form. Success → settings
- Log Out → sheet. Stay closes it. Log out → welcome (`T-APP-006`)
- I Need Help → Safe Space intro
- How the App Work → sheet. Got It closes it

## Allowed files

- `lib/app/modules/profile/**`
- `lib/app/data/repositories/profile_repository.dart` (replace the shop controller’s product usage)
- `lib/app/data/repositories/auth_repository.dart` (password, logout)
- `lib/app/data/models/user_models/**`
- `lib/app/data/mocks/profile.dart`
- `lib/app/data/repositories/app_repository_binding.dart`
- `lib/app/core/network/api_endpoints.dart`
- `lib/app/modules/main_page/**` (person tab)
- `lib/app/routes/app_pages.dart`
- `lib/app/routes/app_routes.dart`
- `assets/images/avatar_*.png`
- `assets/icons/ic_profile_*.svg`
- `assets/icons/ic_settings.svg`
- This file (Status / Notes)

## Done when

- `flutter analyze` is clean
- `flutter test` passes
- Runs on a simulator
- The six screenshots in this task match at 375×812
- Toggles persist through the settings mock
- Log out clears the session and lands on welcome
- Notifications does not open a screen
- Class cannot be edited
- No Parent row

## Notes

-
