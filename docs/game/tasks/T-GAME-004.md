# T-GAME-004 — Shootout, XP, and round complete

**Status:** Done
**Pair:** `wings_of_power_backend/docs/tasks/T-BE-GAME-004.md`
**Phase:** 1
**Depends on:** T-GAME-003 and T-BE-GAME-004
**Plan:** `wings_of_power_app/docs/game/GAME_PLAN.md`

## Goal

After a quarter’s questions, a player who earned a ball swipes to shoot. The server decides make, miss, XP, and the Vs number. Round complete shows both teams and waits for the server before the next quarter.

## In scope

- Single-shot court from `single_shot/`: 00:60 from `deadlineAt`, “Swipe to Shoot!”, shooter identity from `shootout:start`.
- The swipe sets a local `made` boolean from whether the gesture ends in the hoop area. Send `shootout:swipe` once. Do not add XP on the device.
- Make banner “Basket Bonus +2XP”. Miss banner “Oops! So Close!” and “+0 XP”. Show them only from `shootout:result`.
- Vs pills update from server team scores (3 per make, D23).
- Round complete from `round_complete/Round Complete.png`: title “Round {n} Completed”, two rows labeled with the server team labels (render Team B even though the PNG says Team A twice), kindness coins and XP from the payload, **Play Next Round** acks the server.
- Ignore a swipe from a phone that is not the shooter.

## Out of scope

- Championship court (T-GAME-007 / T-GAME-008).
- Kindness +50 (T-GAME-005). Coins may stay 0 here.
- Physics anti-cheat. The server still rejects a swipe outside the window or from the wrong participant.

## Allowed files

- `wings_of_power_app/lib/app/modules/game/**`
- `wings_of_power_app/lib/app/data/models/game_match.dart`
- `wings_of_power_app/lib/app/data/services/game_socket_service.dart`
- This task file

## Manual test (two simulators)

1. Fixture match, Alex and Casey, through Q1. Arrange for Alex to get a ball (correct answer or steal) and Casey to get none. Only Alex sees the swipe court. Casey sees a waiting state, not a tappable ball.
2. Alex swipes a make. Both phones show Alex’s team Vs number at 3 and XP at 2. Casey swiping on his waiting screen does not change the numbers.
3. Replay a ball and swipe a miss (or wait out 60s). Both phones show +0 XP and the Vs number unchanged.
4. Round complete lists Team A and Team B with the same coins and XP on both phones. Play Next Round on either phone advances both, once the server says so.
5. Solo bot match: the bot’s made shot moves the opponent’s score without a second phone. The second simulator, in a different match, keeps its own score.

## Done when

- The script passes on two simulators.
- `flutter analyze` and `flutter test` pass. Debug build passes.
- Status and Notes updated.

## Notes

- Added `GameShootoutStartEvent`, `GameShootoutResultEvent`, `GameRoundTeamSummary`, and `GameRoundCompleteEvent` models in `game_match.dart`.
- Extended `GameSocketService` with observables, streams, and handlers for `shootout:start`, `shootout:result`, and `round:complete`.
- Implemented `SingleShotCourtView` with 60s countdown timer, shooter vs opponent waiting screen, upward pan gesture detection calculating `made` boolean, single-shot flight animation, live Vs pills score update, and make/miss result banners ("Basket Bonus +2XP" vs "Oops! So Close! +0 XP").
- Implemented `RoundCompleteView` featuring star cluster, purple ribbon with "Round {n} Completed", cards for both Team A and Team B (properly rendering Team B even though Figma art showed Team A twice), kindness coin & XP chips, and "Play Next Round" CTA button.
- Wired offline/mock game flow in `GameSocketService` and `GamePlayController` to seamlessly test the entire Q1 question -> shootout -> round complete loop without backend server running.
- Validated with `flutter analyze` (0 issues) and `flutter test` (all passed).
