# T-GAME-010 — Leave, drop, and rejoin

**Status:** done
**Pair:** `wings_of_power_backend/docs/tasks/T-BE-GAME-010.md`
**Phase:** 2
**Depends on:** T-GAME-009 and T-BE-GAME-010
**Plan:** `wings_of_power_app/docs/game/GAME_PLAN.md`

## Goal

The leave sheet matches the design. A short network blip restores the same question. A real leave tells the other phone and does not pause their clock. Rejoin uses the snapshot and cannot answer a closed question.

## In scope

- X on the question board opens `leaving_the _game/Leaving Game.png`: “Leave the match?” / “Your team will keep playing!” Stay dismisses. Leave sends `match:leave` and `POST /api/game/matches/:id/leave`, then mode select.
- Toast from `After leaving.png` on the other phone: “Player Left! {name} left this game. You can continue this game to earn points and shoots.”
- On socket drop, show no toast during the first 15 seconds. If the snapshot returns in time, restore the board, selection cleared, clock from `deadlineAt`.
- If the server has closed the question, the rejoining phone shows the waiting or result state and the answer controls stay disabled.
- Forfeit result uses the same winner card as T-GAME-008 when `match:finished` arrives early.

## Out of scope

- Safe Space pause. Nothing in the client pauses the match timer.
- 5v5 empty-team copy beyond the same toast. The server decides forfeit.

## Allowed files

- `wings_of_power_app/lib/app/modules/game/**`
- `wings_of_power_app/lib/app/data/services/game_socket_service.dart`
- `wings_of_power_app/lib/app/data/repositories/game_repository.dart`
- This task file

## Manual test (two simulators)

1. Start a real 1v1 (Alex and Casey) and reach a buzz window. Alex taps X, then Stay. The question is still there on both phones.
2. Alex taps Leave. Casey sees the Player Left toast and can still buzz and answer. Alex is on mode select and a further answer emit is not on the wire. Casey can finish the question. The clock on Casey did not reset when Alex left.
3. New match. Toggle airplane mode on Alex for 5 seconds during a 10s answer window. No Player Left toast on Casey. Alex reconnects into the same `matchId`. If the deadline is still ahead, Alex can submit. If it has passed, the controls are dead and the server result stands.
4. New match. Leave Alex in airplane mode through the grace period and the 60s forfeit window while Casey stays. Casey eventually gets `match:finished` with Casey’s side as winner. Kindness Casey already earned is still on the leaderboard. Alex’s reconnect shows the finished snapshot, not a new question.
5. Repeat the 5-second blip on a bot practice match on simulator 1 while simulator 2 watches a different match. Simulator 2’s match id does not change.

## Done when

- The script passes on two simulators.
- `flutter analyze` and `flutter test` pass. Debug build passes.
- Status and Notes updated.

## Notes

- Close button (X) on game board / hold view triggers `GameLeaveConfirmModal` with "Stay" (dismisses) and "Leave" (emits `match:leave`, posts `POST /api/game/matches/:id/leave`, disconnects socket, navigates to `Routes.GAME_MODE_SELECT`).
- `match:peer_left` socket event triggers `GamePeerLeftBanner` overlay ("Player Left! {name} left this game. You can continue this game to earn points and shoots.") without interrupting or resetting match clock.
- Socket drop and reconnect grace handled; rejoining phone restores question from snapshot, clears selection, and restores clock from `deadlineAt`. If deadline expired while disconnected, options stay disabled and waiting state is displayed.
- Forfeit victory displays winner screen via `match:finished`.
- Offline and mock simulation helpers added to `GamePlayController` (`simulatePeerLeft`, `simulateForfeit`, `simulateMockDrop`, `simulateMockReconnect`).
