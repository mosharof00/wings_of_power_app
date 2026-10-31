# T-GAME-003 — Countdown, quarter intro, Q1 question round

**Status:** Not started
**Pair:** `wings_of_power_backend/docs/tasks/T-BE-GAME-003.md`
**Phase:** 1
**Depends on:** T-GAME-002 and T-BE-GAME-003
**Plan:** `wings_of_power_app/docs/game/GAME_PLAN.md`

## Goal

Both phones on a fixture match see the same countdown, the same Warm-Up intro, and the same Q1 question. Only the buzz winner’s phone can pick an answer. Nobody’s phone contains the correct option until the server result arrives.

## In scope

- Countdown overlay (`countdown/Countdown.png`) driven by `match:countdown`. Draw 3, then 2, then 1 from `deadlineAt`, even though the PNG shows the last frame. Caption “Get Ready….”
- Quarter intro (`round_intro_card/Quarter 1.png` and the Q2–Q4 cards when those events arrive). The button sends an ack the server defines (`round:intro_ack` only if T-BE-GAME-003 added it to REALTIME.md). The client also just waits if the server auto-advances.
- Q1 board from `buzzer_and_quiz_round/`: title, Vs pills (values from the server, starting at 0), prompt, `index/total`, Buzz, then options only after `round:buzz_winner`.
- Waiting copy: “Your Teammate is Playing” or “{name} from Team {label} is Playing”.
- Selected option is local highlight only. Submit `round:answer`. Correct and wrong banners appear only from `round:answer_result`.
- Pass Now is disabled when `you.canPass` is false (1v1 and bot matches).
- Next stays locked. Do not locally advance on timer expiry. Show the server clock from `deadlineAt`.
- Steal is the same buzz UI when the server opens a steal window. Do not invent a second screen.

## Out of scope

- Shootout, kindness, powers, Q4 vote resolution UI (those events may arrive; a later task paints them). If Q2 starts before T-GAME-005, show the prompt and a disabled body rather than a fake score.
- Computing correctness on the device.

## Allowed files

- `wings_of_power_app/lib/app/modules/game/**`
- `wings_of_power_app/lib/app/data/models/game_match.dart`
- `wings_of_power_app/lib/app/data/services/game_socket_service.dart`
- This task file

## Manual test (two simulators)

1. Alex and Casey join the same `fixtureCode` match.
2. Both see 3-2-1 together (within a second), then the Warm-Up card. Alex taps Open Your First Quiz. Casey’s phone leaves the card too, without Casey tapping, once the server advances.
3. Both see question 1/5 and Buzz. The board shows no option list until `round:buzz_winner`. Logged `round:question` may include option text (that is the contract) and must not include a correct index.
4. Alex buzzes. Alex sees options and “You buzzed first!”. Casey sees the waiting line with Alex’s name and cannot select an option. Casey’s Pass and Buzz do nothing.
5. Alex picks “Walk past” (wrong on the seeded first question). Both phones then show the wrong result the server sends. Casey gets a steal buzz. Casey answers “Help them to pick”. Both phones show Casey’s team earned the result. Alex cannot answer the steal.
6. Repeat a question and let the 10s buzz expire. Both phones move together. Neither phone moves early if its local clock is skewed: set simulator 1’s displayed countdown beside a `deadlineAt` that is still in the future and confirm the phase does not change until the server event.
7. Solo bot match on one simulator still reaches a buzz result without a second human. The other simulator stays on its own match and does not see these questions.

## Done when

- The script passes on two simulators.
- `flutter analyze` and `flutter test` pass. Debug build passes.
- Status and Notes updated.

## Notes

-
