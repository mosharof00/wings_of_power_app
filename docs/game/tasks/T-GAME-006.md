# T-GAME-006 — Q3 powers on a one-person team

**Status:** Done
**Pair:** `wings_of_power_backend/docs/tasks/T-BE-GAME-006.md`
**Phase:** 1
**Depends on:** T-GAME-005 and T-BE-GAME-006
**Plan:** `wings_of_power_app/docs/game/GAME_PLAN.md`

## Goal

Hobby Hoops plays like Q1, and the buzz winner can use their hero power once. The phone shows the banner and applies only the effect object the server sends. Harmony does nothing useful in 1v1.

## In scope

- Intro `round_intro_card/Quarter 3.png`.
- Question chrome from `round_3/hobby_quize_screen_and_power/` and `questions_with_powers/`: buzz, 00:10, options, power chips along the bottom for powers the server says are usable.
- Bolt opens Team Power Wings (`team_details_and_power_view /`). Before Q3, **Not Available!** and Keep Playing. During Q3, the list matches the snapshot (name, power label, who holds it).
- `power:use` on chip tap. Banner from `power:effect` using the map in the plan. Then apply `removedOptions`, `deadlineAt`, `hint`, or `weights`. Never hide an option the server did not list.
- Hint text is the server string, shown in the blue hint box on the question card.
- Prism weights render as percent labels. If a weight is missing, show nothing rather than guessing.
- Harmony chip: send `power:use` only if the server listed it. On `NO_TEAMMATE`, show no Ask-for-help flow.
- `powerUsed` from the snapshot disables the chip for the rest of the match.

## Out of scope

- Teammate help suggestions (T-GAME-012).
- Using a power on Q1, Q2, or Q4. The server will reject it; the client hides chips outside Q3.
- Showing `Quarter 3-3.png` (“You got a hint!”).

## Allowed files

- `wings_of_power_app/lib/app/modules/game/**`
- `wings_of_power_app/lib/app/data/models/game_match.dart`
- `wings_of_power_app/lib/app/data/services/game_socket_service.dart`
- This task file

## Manual test (two simulators)

1. Fixture match through Q2. Both phones show Hobby Hoops and Buzz. Open the bolt on Q1’s next replay if you can catch it earlier in a fresh match: Not Available. During Q3 the sheet lists both players’ powers.
2. Alex, with Lab (Harold) or whichever hero the seed gave them, buzzes and uses the power. Two options disappear on Alex’s phone only if `removedOptions` says so. Casey’s waiting phone does not reveal the answer. The correct option, once Alex answers, was not one of the removed ones.
3. Second question: Alex’s power chip is gone. Casey can use Casey’s own power on a question Casey wins. A second use from Alex is ignored (no second banner).
4. Melody or Color: the ring gains about 10 seconds on both phones’ clocks, because `deadlineAt` moved.
5. Nature or Story: the hint box text matches the event and is not the answer sentence.
6. A 1v1 Harmony hero shows no working Ask for help. Solo bot match: the human can still use one non-Harmony power; the bot does not need a power for this test.

## Done when

- The script passes on two simulators.
- `flutter analyze` and `flutter test` pass. Debug build passes.
- Status and Notes updated.

## Notes

- Quarter 3 "Hobby Hoops" support implemented with round intro card and 5 MCQ buzz questions.
- GameMatchParticipant and GameMatchYou updated with power fields, copyWith, and GamePowerEffectEvent model.
- HeroPowerInfo helper maps hero and power codes to character art, labels, descriptions, and banner titles/subtitles per GAME_PLAN.md.
- Power chips displayed along the bottom of the question card during Q3 only for usable powers.
- Bolt button opens Team Power Wings sheet: displays "Not Available!" before Q3 and full snapshot player powers list during Q3 with active/used pills.
- Power chip tap emits `power:use { roundId, powerCode }` when answering in Q3.
- `power:effect` socket event handling:
  * GamePowerBannerOverlay displays 3D character glow, purple ribbon title, and effect subtitle.
  * `removedOptions`: disables and hides only specified option indices.
  * `deadlineAt` / `extraMs`: updates timer countdown ring.
  * `hint`: renders blue hint box on the question card.
  * `weights`: renders percent badges on options (omits missing weights).
- Single use per match enforced (`hasUsedPower == true` disables chip for match).
- Harmony in 1v1 / single player bypasses ask-for-help flow.
- Offline mock mode support in GameSocketService and GamePlayController for Q3 progression and power activations.
- `flutter analyze` and `flutter test` passed with 0 issues.
