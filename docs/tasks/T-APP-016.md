# T-APP-016 — Safe Space and Kindness Corner

**Status:** todo

**Depends on:** T-APP-010, T-APP-004

## Scope

Safe Space screens. Kindness Corner has no student screenshot.

### Safe Space

`student.safe_space_intro`, `student.safe_space_form`, `student.safe_space_done`, `student.my_reports`, `student.report_detail`.

Intro promises, as printed on `Safe Space Reports.png`: no points impact; never public; not shared with students. Tell Us What Happened.

Form, three steps:

| PNG | Step |
|-----|------|
| `safe.png` | 1/3 category |
| `safe-1.png` | 2/3 text, 0/200 |
| `safe-2.png` | 3/3 feel safe Yes/No |

Next, Submit Report, Cancel. Body max 200 (`POST /api/safe-space/reports`: `category`, `body`, `feelSafe`).

Submission Complete: report id as on the PNG (`WP-1548` in the fixture). The API field is the create response public ref (`MODULE_MAP` `public_ref`). View My Report, Back to Home.

My Reports: filters New / Reviewing / Addressed, rows, dates. The same list is exported as:

- `safe_space_reporting/My Reports.png`
- `profile/My Reports.png`

One screen. Profile “My Reports” and this list are the same route.

Report detail is a sheet: status, id, category, date, narrative, Close. Student payload has no staff notes (`GET` own report only).

Settings “I Need Help” (`T-APP-017`) and the home Safe Space tile open the intro. Decision 9: Help opens this report flow.

Mock until `T-BE-015`.

### Kindness Corner

The home tile is drawn in `T-APP-010`. There is no student destination PNG (only `design/screens/admin/storie/Kindness Corner.png`). `GET /api/content/kindness-corner` is P2. This task does not build a Kindness Corner screen and does not call that endpoint.

## Screenshots

- `design/screens/student/safe_space_reporting/Safe Space Reports.png`
- `design/screens/student/safe_space_reporting/safe.png`
- `design/screens/student/safe_space_reporting/safe-1.png`
- `design/screens/student/safe_space_reporting/safe-2.png`
- `design/screens/student/safe_space_reporting/Submission Complete.png`
- `design/screens/student/safe_space_reporting/My Reports.png`
- `design/screens/student/profile/My Reports.png`
- `design/screens/student/safe_space_reporting/Reports Details.png`

## Assets

- `assets/icons/ic_safe_space.svg` (also used by the home tile)
- `assets/characters/safe_space_intro.png` if the intro PNG has an illustration beyond the icon

## API

Mock until `T-BE-015`:

- `POST /api/safe-space/reports` — `category`, `body` ≤ 200, `feelSafe`
- `GET /api/safe-space/reports` — `status` filter, paginated
- `GET /api/safe-space/reports/:id` — own report, no staff notes

No Kindness Corner call.

## States

- Intro
- Step 1 category, Next disabled until a category is chosen
- Step 2 empty (0/200) and with text
- Step 2 over 200 characters blocked in the field
- Step 3 Yes and No
- Submit loading
- Submission complete
- List: New, Reviewing, Addressed, and empty
- Detail sheet
- Cancel returns home without posting

## Navigation

- In: home Safe Space Report; profile My Reports (list, not intro); settings I Need Help (intro)
- Tell Us What Happened → step 1
- Submit → complete
- View My Report → detail
- Back to Home / Cancel → home
- Filter chips reload the list
- Row → detail sheet
- Close → list

## Allowed files

- `lib/app/modules/safe_space/**` (new)
- `lib/app/data/repositories/safe_space_repository.dart`
- `lib/app/data/models/safe_space_models.dart`
- `lib/app/data/mocks/safe_space.dart`
- `lib/app/data/repositories/app_repository_binding.dart`
- `lib/app/core/network/api_endpoints.dart`
- `lib/app/routes/app_pages.dart`
- `lib/app/routes/app_routes.dart`
- Assets named above
- This file (Status / Notes)

## Done when

- `flutter analyze` is clean
- `flutter test` passes
- Runs on a simulator
- Each Safe Space screenshot matches at 375×812 (the two My Reports exports are one screen)
- Submit sends category, body, and feelSafe
- No Kindness Corner screen and no staff-note UI

## Notes

-
