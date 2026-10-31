# T-GAME-011 — 5v5 lobby and odd counts

**Status:** Not started
**Pair:** `wings_of_power_backend/docs/tasks/T-BE-GAME-011.md`
**Phase:** 3 — 5v5
**Depends on:** T-GAME-010 and T-BE-GAME-011
**Plan:** `wings_of_power_app/docs/game/GAME_PLAN.md`

## Goal

Multi Player opens the ten-seat waiting room. A partial room cannot start. A full room can. Teams on the phone are exactly the teams in `match:found`.

## In scope

- Multi Player sends `{ mode: "FIVE_V_FIVE" }`.
- Waiting room from `waiting_room /Waiting room.png`, `-1.png`, and `-2.png`:
  - “Finding your classmates...” and “[n out of 10] is here” while filling. Empty seats are “?” and “Waiti…”.
  - “Only {n} classmates were found” / “Wait for others to join” when the server marks the room partial and at least one other player is in it. Buttons stay Back to Lobby and Explore Stories. No Start Game.
  - “All Classmates are found” / “[10 out of 10] is here” with Start Game and Cancel.
- Team A and Team B lists use server membership. “You” marks the local user. Avatars and nicknames, not heroes.
- A started match uses the same quarter flow. Vs pills still say Team A and Team B.

## Out of scope

- Pass, Harmony, and five-person voting UI details (T-GAME-012). They may already work if the server says so; this task does not finish them.
- Padding empty seats with bots. If a face is not in `queue:update`, it stays a placeholder.

## Allowed files

- `wings_of_power_app/lib/app/modules/game/**`
- `wings_of_power_app/lib/app/data/services/game_socket_service.dart`
- `wings_of_power_app/lib/app/data/models/game_match.dart`
- This task file

## Manual test (two simulators)

The other seats are real seeded students connected by `yarn game:queue-fixtures` from the server task, not bots and not a third mode.

1. Alex and Casey tap Multi Player. Both show a 10-seat board, two faces, and no Start Game. Back to Lobby on Alex removes Alex’s face on Casey’s phone.
2. Queue Alex and Casey again. Run the fixture command so two more students join (four humans total). The server’s `others` count is 3. Both phones show “Only 3 classmates were found” and “Wait for others to join”. Start Game is absent. Back to Lobby and Explore Stories are the only actions.
3. Run the command up to 10 total. Both phones show Start Game and ten nicknames. Start on one phone countdowns both. Each phone’s Team A and Team B match the other phone’s lists.
4. Cancel from the full room before start. Both return toward the lobby or a smaller queue together, as the server sends. The next queue does not reuse the cancelled match id.
5. A 9-person room (stop the command at 9) never shows Start Game on either phone.

## Done when

- The script passes on two simulators.
- `flutter analyze` and `flutter test` pass. Debug build passes.
- Status and Notes updated.

## Notes

-
