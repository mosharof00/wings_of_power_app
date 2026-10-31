# T-APP-005 — Splash and onboarding

**Status:** done

**Depends on:** T-APP-004

## Scope

`student.splash`, `student.onboarding`.

First launch: splash, then three onboarding pages, then the welcome route from `T-APP-006`. Later launches: splash, then welcome if there is no session, or the post-login destination if a session exists (`T-APP-008` / pending screen). Store “onboarding seen” in Hive.

Splash keeps a short wait, then navigates. The spinner on the PNG is the loading indicator.

## Screenshots

- `design/screens/student/splash_onboarding/Splash Screen.png`
- `design/screens/student/splash_onboarding/Onboarding1.png` — Stories That Inspire
- `design/screens/student/splash_onboarding/Onboarding2.png` — Safe Space to Speak Up
- `design/screens/student/splash_onboarding/Onboarding3.png` — Learn, Play & Grow

## Assets

| File | Use |
|------|-----|
| `assets/backgrounds/bg_splash_sky.png` | Splash sky and clouds |
| `assets/logos/logo_wordmark.png` | “Wings of Power” + butterfly |
| `assets/onboarding/onboarding_stories.png` | Page 1 illustration |
| `assets/onboarding/onboarding_safe_space.png` | Page 2 |
| `assets/onboarding/onboarding_play.png` | Page 3 |

Export is empty. Until those files exist, use a placeholder image of the same aspect in that path so layout can be checked. Copy the illustration out of the screenshot only into these named files, not the whole phone frame (status bar and home indicator stay system chrome).

## API

No API. Local only (`MODULE_MAP`).

## States

- Splash with spinner
- Onboarding page 1, 2, 3 (dots)
- Skip on 1 and 2
- Next on 1 and 2
- Get Started on 3

## Navigation

- In: app start (`Routes.SPLASH`)
- Out: Skip or Get Started → welcome (`T-APP-006`). If onboarding was already seen, splash skips it
- Session present: splash → home shell, or account verification when `GET /api/auth/me` is `PENDING` (mock until `T-BE-010`; until 007 exists, go to the home shell)

## Allowed files

- `lib/app/modules/splash/**`
- `lib/app/modules/onboarding/**` (new)
- `lib/app/routes/app_pages.dart`
- `lib/app/routes/app_routes.dart`
- `lib/app/core/services/local_store_service.dart` (onboarding flag, if that is the Hive wrapper)
- `assets/backgrounds/bg_splash_sky.png`
- `assets/logos/logo_wordmark.png`
- `assets/onboarding/**`
- This file (Status / Notes)

## Done when

- `flutter analyze` is clean
- `flutter test` passes
- Runs on a simulator
- Splash and all three onboarding pages match their screenshots at 375×812
- Skip and Get Started leave onboarding and do not show it again on the next cold start

## Notes

- Splash waits 2 seconds, then: session → `Routes.MAIN_PAGE` (account verification is T-APP-007); guest who has not seen onboarding → `Routes.ONBOARDING`; guest who has → `Routes.WELCOME`.
- “Onboarding seen” uses the existing Hive helpers `HiveService.getOnBoardShowed` / `setOnBoardShowed` (box `appData`, key `onboard`). `local_store_service.dart` was not changed.
- Skip (pages 1–2) and Get Started (page 3) both call `finish()`, which sets that flag and opens `/welcome`.
- `/welcome` is a blank `Scaffold` until T-APP-006 replaces it.
- Onboarding titles use measured color `#104F6F`, Nunito 26sp w800 / body 14sp. Theme text slots stop at 18 and theme files are outside this task, so these styles live on the onboarding view.
- Dots are `StepProgress`. The splash spinner is a 10-dot white ring.
- Assets: `assets/backgrounds/bg_splash_sky.png`, `assets/logos/logo_wordmark.png` (sky pixels transparent), `assets/onboarding/onboarding_stories.png`, `onboarding_safe_space.png`, `onboarding_play.png`. `lib/gen/assets.gen.dart` was regenerated so those getters exist.
- Checked on the iPhone 18 Pro Max simulator: splash (wordmark, sky, spinner), all three onboarding pages, finish landing on the blank welcome screen, and a later cold start that skips onboarding.
- `flutter analyze` clean. `flutter test`: 10 passed.
