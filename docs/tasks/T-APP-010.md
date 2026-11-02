# T-APP-010 — Home

**Status:** done

**Depends on:** T-APP-004, T-APP-008

## Scope

`student.home`. The lock modal `student.game_show_locked` is `docs/game/tasks/T-GAME-001.md`.

Home is the first tab of the shell from `T-APP-004`.

Body, from the PNGs:

- Greeting (“Hey Sarah!”), points chip, bell
- Search
- First-story banner (Start Reading) on the new-student frames
- Book Categories carousel
- Popular Stories, See all
- Play Game banner
- Explore More: Kindness Corner, Audio Books, Safe Space Report

`Home-3.png` is part of this screen (`student.home`) and was not described pixel-by-pixel in the inventory. Open it and match it if it is another home state. If it is a broken export, stop and add a line to `docs/OPEN_QUESTIONS.md` instead of inventing the missing region.

**Play Game** is a button on the banner. Leave `HomeController.onPlayGame` empty for `T-GAME-001`, which owns eligibility, `Game show.png`, the congratulations modal, and mode select. This task does not call `GET /api/game/eligibility` and does not add a game route.

Bell, Kindness Corner, and Audio Books are drawn and have no route (D14). Safe Space Report → `T-APP-016`. See all and Start Reading / Continue → story library or the continue story from `GET /api/student/home`. Search on this screen filters the popular list locally until `T-APP-011`; submitting search may also open the library with the query.

The basketball nav icon stays inert (`T-APP-004`).

Mock until `T-BE-011`. Fixture covers the new-student banner and the returning home (`Home-2.png`). The home payload’s eligibility flag can be ignored; `T-GAME-001` reads eligibility itself.

## Screenshots

- `design/screens/student/home/Home.png`
- `design/screens/student/home/Home-1.png`
- `design/screens/student/home/Home-2.png`
- `design/screens/student/home/Home-3.png`

`design/screens/student/home/Game show.png` is matched in `T-GAME-001`, not here.

## Assets

- `assets/backgrounds/bg_home_sky.png`
- `assets/characters/home_banner_reader.png` — banner child
- `assets/characters/home_play_game.png` — Play Game banner
- `assets/icons/ic_bell.svg`
- `assets/icons/ic_kindness_corner.svg`, `ic_audio_books.svg`, `ic_safe_space.svg` — Explore More circles
- Category and cover art used by the cards from `T-APP-004` (`assets/book_covers/`, category illustrations)

## API

Mock until `T-BE-011`:

- `GET /api/student/home` — greeting, points total, continue story, popular, eligibility flag (display only; the game task interprets it)

## States

- New student, top of the page (`Home.png`)
- Long scroll with categories, popular, Play Game, Explore More (`Home-1.png`)
- Returning home (`Home-2.png`)
- `Home-3.png` once opened
- Home loading and home error (shared widgets)

## Navigation

- In: login success; account already `ACTIVE`
- Start Reading / Continue / See all / a cover → `T-APP-011`
- Play Game → `onPlayGame` (filled by `T-GAME-001`)
- Safe Space Report → `T-APP-016`
- Book tab, badge tab, person tab → those tasks
- Bell, Kindness Corner, Audio Books, basketball tab: no route in this plan

## Allowed files

- `lib/app/modules/home/**`
- `lib/app/modules/main_page/**` (wire the home tab only)
- `lib/app/data/repositories/home_repository.dart`
- `lib/app/data/models/home_models.dart`
- `lib/app/data/mocks/home.dart`
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
- `Home.png`, `Home-1.png`, `Home-2.png`, and `Home-3.png` (if it is a home state) match at 375×812
- Play Game is on the page and its handler is the empty `onPlayGame` hook
- Kindness Corner, Audio Books, and the bell do not open a made-up screen

## Notes

- Student home screen implemented matching home_default.png (Home.png), home_game_unlocked.png (Home-1.png), home_story_in_progress.png (Home-2.png), and home_all_stories_complete.png (Home-3.png) at 375x812.
- Top header: greeting, PointsChip, avatar, and bell icon (inert / no route per D14).
- Search bar: SearchField filtering popular stories locally on text change.
- Dynamic banner card: start reading ("Start your first story!" / "Start Reading"), continue reading ("Keep going!" / progress bar / "Continue"), and quiz ("Finish your quiz to unlock next chapter!" / "Take the Quiz").
- Book categories: carousel PageView with centered 3D scale/fade animation.
- Popular stories: 2-column grid cards with title, cover, subtitle. "See all" and covers route to Stories shell tab.
- Play Game banner: "Ready to Take the Shot?" with basketball hero and empty `onPlayGame` hook for T-GAME-001.
- Explore More: Kindness Corner and Audio Books (inert / no route per D14); Safe Space Report navigates to `Routes.SAFE_SPACE_REPORT` stub (T-APP-016 placeholder).
- HomeMock fixture in `lib/app/data/mocks/home.dart` covers newStudent, inProgress, quiz, and errorOverride states.
- HomeRepository wired in `AppRepositoryBinding` and `HomeBinding` with ApiClient.
- Validation: flutter analyze clean, flutter test passed (10 repo tests + 7 home verification tests).
