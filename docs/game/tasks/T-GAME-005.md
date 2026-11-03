# T-GAME-005 — Defense round and kindness

**Status:** Done
**Pair:** `wings_of_power_backend/docs/tasks/T-BE-GAME-005.md`
**Phase:** 1
**Depends on:** T-GAME-004 and T-BE-GAME-005
**Plan:** `wings_of_power_app/docs/game/GAME_PLAN.md`

## Goal

Q2 shows the story prompt and a text box. Kindness +50 appears only after the server says so. Both phones then shoot or wait together.

## In scope

- Intro card `round_intro_card/Quarter 2.png`: Defense Round, “Read the Story”.
- Question UI from `round_2/Quarter 2.png`: 00:60, prompt, “What would you do?”, text field, Submit enabled only when the field is non-empty.
- Submit sends `round:answer` `{ freeText }`. No local +50.
- Waiting sheet from `Quarter 2-2.png` when `round:waiting` says the other side is still writing.
- Celebration from `Quarter 2-3.png` when `kindnessDelta` is 50: “You’ve earned kindness points +50” and **Play the Shoot**. If the server sends delta 0, do not show this celebration.
- Then the shootout from T-GAME-004 for each ball the server grants.
- Header kindness coins on the mode select update from the server after the match writes the ledger (the in-match coin chip updates from `teamScores.kindness`).

## Out of scope

- Grading the sentence for kindness on the device.
- A “fewer points” amount. There is no screen for one.
- Q3 powers.

## Allowed files

- `wings_of_power_app/lib/app/modules/game/**`
- `wings_of_power_app/lib/app/data/models/game_match.dart`
- `wings_of_power_app/lib/app/data/services/game_socket_service.dart`
- This task file

## Manual test (two simulators)

1. Fixture match. Let Q1 finish (bot or humans). Both phones show the Defense intro, then the Harold prompt (or whatever the pack sent) and 00:60.
2. Alex submits a sentence. Alex sees the waiting sheet until Casey submits or the clock ends. Casey’s phone does not show Alex’s text.
3. After both submit, both see +50 and their own coin chip increases by 50. Play the Shoot opens a shootout only if the server sent a ball.
4. New match. Alex submits empty by waiting out the clock (Submit stays disabled). Alex does not see +50. Casey, who submitted, still sees +50 on Casey’s phone only.
5. Confirm logged `round:question` for Q2 has no hidden correct answer.

## Done when

- The script passes on two simulators.
- `flutter analyze` and `flutter test` pass. Debug build passes.
- Status and Notes updated.

## Notes

- Implemented `GameRoundIntroCard` dynamic quarter presentation ("Round 2", "Defense Round", "Read the Story").
- Implemented `GameFreeTextBoard` widget rendering 60s countdown clock, Harold scenario prompt, "What would you do?", multi-line text input with hint "Write your answer here......", and "Submit" CTA enabled only when text is non-empty.
- Added `GameWaitingOverlay` displaying "Waiting for your classmates" and "One of your classmates is still thinking" when answer is submitted while others write.
- Added `GameKindnessCelebrationDialog` displaying "Congratulations!", "You've earned kindness points", "+50 Kindness points" gold badge, and "Play the Shoot" CTA when `kindnessDelta == 50`. If `kindnessDelta == 0`, celebration is suppressed.
- Implemented `GameKindnessResultEvent` model and wired socket listeners in `GameSocketService` for `round:kindness_result` and `round:answer_result` with `kindnessDelta`.
- Implemented complete offline/mock mode support: Q2 prompt -> free text -> waiting state -> +50 kindness celebration -> shootout swipe -> round 2 complete with updated kindness coins (295).
- All Flutter analysis checks (`flutter analyze`) and tests pass with zero warnings or errors.
