# T-GAME-002 — Hero, avatar, and a live practice socket

**Status:** Not started
**Pair:** `wings_of_power_backend/docs/tasks/T-BE-GAME-002.md`
**Phase:** 1
**Depends on:** T-GAME-001 and T-BE-GAME-002
**Plan:** `wings_of_power_app/docs/game/GAME_PLAN.md`

## Goal

Alex can pick an unlocked power hero and a face avatar, then start a practice match. The phone connects with the JWT, joins the match, and renders a snapshot. It does not decide the opponent, the score, or the phase.

## In scope

- Choose Power Hero modal (`Choose Hero.png`) via `GET /api/heroes` and `POST /api/heroes/:id/select`. Locked heroes do not select.
- Change Avatar modal (`Change Avatar.png`) via `PATCH /api/student/profile`. Faces are not heroes.
- Add `socket_io_client` in `pubspec.yaml`. One socket service owned by the game module. Handshake `auth: { token }`.
- Practice entry: until T-GAME-009, Single Player calls `POST /api/game/queue` with `{ mode: "SINGLE" }`. A debug field can send `fixtureCode` when the developer types one. No student-facing code UI is required beyond a debug-only text field behind an existing developer flag if the app already has one; otherwise a hidden long-press on Single Player that asks for the code is enough for the two-phone test. Do not add a third mode card.
- On `match:found` / `match:snapshot`, store teams, your participant id, phase, and `deadlineAt`. Show a plain “Match ready” hold screen if the countdown task is not done yet. Opponent for a solo practice is the bot seat from the server (`isBot: true`), labeled as the server sends.
- Disconnect the socket on leave of the game module.

## Out of scope

- Rendering questions, buzz, or scores (later tasks).
- Public 1v1 or 5v5 queues.
- Inventing an eighth hero name. If the API returns seven heroes, show seven.

## Allowed files

- `wings_of_power_app/lib/app/modules/game/**`
- `wings_of_power_app/lib/app/data/models/hero.dart`
- `wings_of_power_app/lib/app/data/models/game_match.dart`
- `wings_of_power_app/lib/app/data/repositories/igame_repository.dart`
- `wings_of_power_app/lib/app/data/repositories/game_repository.dart`
- `wings_of_power_app/lib/app/data/services/game_socket_service.dart` (new)
- `wings_of_power_app/pubspec.yaml` (socket client only)
- This task file

## Manual test (two simulators)

1. Alex on simulator 1 opens Choose Hero, selects an unlocked hero, closes the sheet, and sees the selection stick after a restart. A locked hero does not stick.
2. Alex opens Change Avatar, picks a different face, taps Save. Simulator 2 (Blake, or a second login of a third eligible student Casey) is not required to see Alex’s avatar yet. Confirm with a refetch on simulator 1 only.
3. Solo: Alex taps Single Player with no fixture code. The snapshot shows Alex plus one bot, mode `SINGLE`, phase countdown or matched as the server sends. No `correctIndex` anywhere in logged events.
4. Pair: set the same `fixtureCode` on both simulators (Alex and Casey, both eligible). Both snapshots show the same `matchId`, two humans, zero bots. Blake cannot queue if you try from the ineligible account; the server error is shown, not a local match.
5. Airplane-mode simulator 1 for five seconds and restore. It reconnects and gets a snapshot for the same match. It must not create a second match.

## Done when

- The script passes on two simulators.
- `flutter analyze` and `flutter test` pass. Debug build passes.
- Status and Notes updated.

## Notes

-
