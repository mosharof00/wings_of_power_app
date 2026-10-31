# T-GAME-001 — Unlock, mode select, how to play

**Status:** Not started
**Pair:** `wings_of_power_backend/docs/tasks/T-BE-GAME-001.md`
**Phase:** 1 — playable 1v1 against a bot or fixture
**Depends on:** server pair T-BE-GAME-001
**Plan:** `wings_of_power_app/docs/game/GAME_PLAN.md`

## Goal

From Home, an ineligible student sees the lock modal. An eligible student sees the congratulations modal once, then the basketball mode select and the How to Play sheet. Thresholds come from the eligibility payload.

## In scope

- New GetX module `lib/app/modules/game/` for these screens only.
- Home **Play Game** calls `GET /api/game/eligibility` through a repository and `ApiClient`.
- Lock modal copy and actions from `design/screens/student/home/Game show.png`: Continue Reading (back to stories), close.
- Congratulations modal from `play_mood_choosing/Conratulations screen for game unlock.png`: Play Now, How to Play. Show once per eligibility flip (Hive flag is fine).
- Mode select from `Game Show Unlocked.png` and `Game Show Unlocked-1.png`. Single Player and Multi Player are visual states only in this task. Taps do not queue yet.
- How to Play sheet from `How to Play.png`, filled by `GET /api/game/how-to-play`.
- Header avatar, kindness coins, and XP render server fields. They may be zero.

## Out of scope

- Hero modal, avatar modal, sockets, queue, waiting room, quarters.
- Hardcoded 2/6/70 in the widget. Display `rules` from the API.
- Leaderboard redesign.

## Allowed files

- `wings_of_power_app/lib/app/modules/game/**`
- `wings_of_power_app/lib/app/data/models/game_eligibility.dart`
- `wings_of_power_app/lib/app/data/models/how_to_play.dart`
- `wings_of_power_app/lib/app/data/repositories/igame_repository.dart`
- `wings_of_power_app/lib/app/data/repositories/game_repository.dart`
- `wings_of_power_app/lib/app/routes/app_routes.dart`
- `wings_of_power_app/lib/app/routes/app_pages.dart`
- `wings_of_power_app/lib/app/modules/home/views/home_view.dart` (Play Game entry only)
- `wings_of_power_app/lib/app/modules/home/controllers/home_controller.dart` (same)
- `wings_of_power_app/lib/app/core/**` only to add the two `ApiEndpoint` constants
- This task file (Status and Notes)

## Manual test (two simulators)

1. Boot the API from T-BE-GAME-001. Log Alex in on simulator 1 and Blake in on simulator 2.
2. On Blake, tap Play Game. Confirm the lock modal text matches the PNG (2 stories or 6 chapters, 70%). Continue Reading leaves the modal. Close leaves the modal. Blake never sees mode select.
3. On Alex, tap Play Game. Confirm the congratulations modal, then Play Now lands on mode select with Alex’s avatar. Open How to Play and confirm all five steps. Close it.
4. Tap Single Player, then Multi Player. The highlight swaps as in the two PNGs. Neither tap starts a match or opens a waiting room.
5. Kill and reopen Alex’s app. Congratulations does not show again. Mode select still opens. Blake still sees the lock.
6. Point both simulators at a proxy or log and confirm the eligibility JSON has no answer keys and no other student’s progress.

## Done when

- The script above passes on two simulators.
- `flutter analyze` and `flutter test` pass. Debug build passes.
- Status and Notes on this file are updated.

## Notes

-
