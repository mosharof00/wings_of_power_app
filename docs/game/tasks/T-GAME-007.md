# T-GAME-007 — Wings Final for a team of one

**Status:** Not started
**Pair:** `wings_of_power_backend/docs/tasks/T-BE-GAME-007.md`
**Phase:** 1
**Depends on:** T-GAME-006 and T-BE-GAME-007
**Plan:** `wings_of_power_app/docs/game/GAME_PLAN.md`

## Goal

Q4 is a 20-second team vote after a buzz. In 1v1 that team is one player, so their vote is the whole majority. The other phone waits and does not see the choice until the result sheet.

## In scope

- Intro `round_intro_card/Quarter 4.png`: Wings Final, “Start Championship”.
- Buzz frame `round_4/Buzzer.png`, progress `1/3`.
- Vote frame `round_4/Voting screen.png`: “Team {label} - Vote Now!”, 00:20, **Vote Now**. Send `round:vote`. Do not send the choice in any local broadcast.
- After you vote, the waiting sheet (`Vote waiting screen.png`) only if the server still has teammates out. On a one-person team, skip it when the result arrives immediately.
- Result sheet (`Vote waiting screen-1.png`): “Voting Results”, “Team {label} chose {letter}”, **See the Result!** Letter comes from the server.
- A correct majority earns the ball and the existing shootout. The Vs number moves only from `shootout:result`.
- Championship swipe court (`final_championship/Game.png`) replaces the single-shot court for Q4 balls: roster with per-player XP, 00:60, “Swipe to Shoot!”. Same `shootout:swipe` event.

## Out of scope

- Rendering other teammates’ live votes. Phase 3 fills the waiting sheet for real.
- Final winner card (T-GAME-008). After the last Q4 shot, hold on the server’s next event.

## Allowed files

- `wings_of_power_app/lib/app/modules/game/**`
- `wings_of_power_app/lib/app/data/models/game_match.dart`
- `wings_of_power_app/lib/app/data/services/game_socket_service.dart`
- This task file

## Manual test (two simulators)

1. Fixture match through Q3. Both phones show Wings Final, then question 1/3 and Buzz.
2. Casey buzzes first. Casey sees the vote UI and 00:20. Alex sees the waiting line and no selectable options. Alex’s logs for `round:vote_update` contain counts only, not Casey’s letter.
3. Casey votes A. Both phones show “Team {Casey} chose A” (or B’s label). If that option is the seeded correct one, only Casey gets the championship swipe. Alex cannot swipe it.
4. Casey lets a later question’s 20s expire without voting. Both phones move on with no basket.
5. Solo bot match: when the human buzzes, one vote resolves without a 20s wait for a ghost teammate. When the bot buzzes, the human cannot vote.

## Done when

- The script passes on two simulators.
- `flutter analyze` and `flutter test` pass. Debug build passes.
- Status and Notes updated.

## Notes

-
