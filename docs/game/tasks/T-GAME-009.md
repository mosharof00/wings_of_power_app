# T-GAME-009 — Real 1v1 waiting room

**Status:** Done
**Pair:** `wings_of_power_backend/docs/tasks/T-BE-GAME-009.md`
**Phase:** 2 — real matchmaking
**Depends on:** T-GAME-008 and T-BE-GAME-009
**Plan:** `wings_of_power_app/docs/game/GAME_PLAN.md`

## Goal

Single Player joins the public 1v1 queue and shows the two-seat waiting room. Two eligible students become a match without a fixture code and without a bot. One student keeps waiting.

## In scope

- Single Player now sends `{ mode: "ONE_V_ONE" }`. Remove the phase-1 shortcut that started `SINGLE` from this card. Keep `SINGLE` / `fixtureCode` behind the debug long-press from T-GAME-002.
- Waiting room from `waiting_room /Waiting room-3.png`, `-4.png`, and `-5.png`:
  - “Finding your classmates” / “No one is found” while the other seat is empty. Buttons: Back to Lobby, Explore Stories.
  - “Both players are ready” / “Click below to start the game” when the server says the room is full. Buttons: Start Game, Cancel.
- Slots show avatar and nickname. “Sarah (You)” uses the local nickname plus “(You)”.
- Back to Lobby and Cancel call `DELETE /api/game/queue` or `match:leave` as the server instructs before start. Explore Stories routes to the stories list.
- Start Game sends the server’s ready event (`match:start` if T-BE-GAME-009 added it). Both phones enter the existing countdown together.
- Do not show a bot in this room.

## Out of scope

- 5v5 team grid (T-GAME-011).
- Changing Q1–Q4 rules. A started 1v1 uses the phase-1 match engine with two humans and no bot.

## Allowed files

- `wings_of_power_app/lib/app/modules/game/**`
- `wings_of_power_app/lib/app/data/services/game_socket_service.dart`
- `wings_of_power_app/lib/app/data/repositories/game_repository.dart`
- `wings_of_power_app/lib/app/routes/app_pages.dart` only if Explore Stories needs an existing route constant
- This task file

## Manual test (two simulators)

1. Alex on simulator 1 taps Single Player. The room shows Alex and “Waiti…”. Copy matches the finding / no-one states. No bot face appears. Back to Lobby returns to mode select, and a second tap is a new wait, not a surprise match.
2. Casey on simulator 2 taps Single Player. Both phones flip to “Both players are ready” with both nicknames. Start Game on Alex’s phone runs countdown on both. Cancel on Casey before anyone starts returns both to the lobby and does not leave a half match. (Do this cancel check on a second attempt.)
3. Play the first buzz. The opponent is Casey, not a bot. Scores stay in lockstep through one question.
4. Blake taps Single Player and sees the ineligible error, not a seat.
5. Alex waits alone for the full queue expiry (or the server’s shortened test expiry if Notes document one). The phone returns to mode select. Casey, who queued later, is not pulled into Alex’s expired ticket.

## Done when

- The script passes on two simulators.
- `flutter analyze` and `flutter test` pass. Debug build passes.
- Status and Notes updated.

## Notes

- Implemented `WaitingRoom1v1Controller` and `WaitingRoom1v1View` with 2-seat matching states from designs (`waiting_room_nobody_found.png`, `waiting_room_full_ready.png`, `waiting_room_matched_starting.png`).
- Single Player card now routes through eligibility check and sends `POST /api/game/queue` / `queue:join` with `{ mode: "ONE_V_ONE" }`.
- Debug long-press on Single Player card is retained for solo practice `mode: "SINGLE"` and `fixtureCode`.
- Seat 1 shows "{nickname} (You)" with player avatar; Seat 2 shows "?" / "Waiti..." while searching, and switches to peer avatar and nickname once joined (no bot displayed).
- "Back to Lobby" and "Cancel" cancel queue / leave match and return to mode select; "Explore Stories" routes to `Routes.STORY_LIBRARY`.
- "Start Game" sends `match:start` socket event; smooth transition to `GameMatchHoldView` occurs on countdown event.
- Added full offline / mock mode support in `WaitingRoom1v1Controller` and `GameSocketService.simulateMockMatch` for `ONE_V_ONE` with 0 bots.
- Validated with `flutter analyze` (0 issues) and `flutter test` (all passed).
