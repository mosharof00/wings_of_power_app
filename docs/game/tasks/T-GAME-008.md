# T-GAME-008 — Results and the leaderboard hook

**Status:** Not started
**Pair:** `wings_of_power_backend/docs/tasks/T-BE-GAME-008.md`
**Phase:** 1
**Depends on:** T-GAME-007 and T-BE-GAME-008
**Plan:** `wings_of_power_app/docs/game/GAME_PLAN.md`

## Goal

A finished practice match shows the winner card from the server, then Back to Lobby. A Leaderboard action opens the student leaderboard route. Kindness on that board includes this match’s +50, with avatar and nickname.

## In scope

- Winner card from `final_championship/Round Complete.png`: “Winner - Team {label}”, both rosters (avatar, nickname, not hero name), kindness coins, XP, **Back to Lobby**.
- If `winnerTeamId` is null, show both cards and no Winner ribbon. Do not pick a winner locally.
- **Leaderboard** button on that card. It routes to the existing student leaderboard screen if that route exists. If the screen is still the template, add a thin GetX leaderboard view that lists `GET /api/student/leaderboard` (avatar, nickname, kindness sum) and nothing else. Do not copy character art from the old PNG (decision 5).
- Back to Lobby returns to mode select and clears the match socket room state.
- Mode-select coin chip refetches so Alex’s new kindness shows.

## Out of scope

- Teacher dashboard leaderboard.
- Badges, Game Show Ready badge logic.
- Announcer audio.

## Allowed files

- `wings_of_power_app/lib/app/modules/game/**`
- `wings_of_power_app/lib/app/modules/leaderboard/**` (only if no leaderboard module exists yet)
- `wings_of_power_app/lib/app/data/repositories/igame_repository.dart`
- `wings_of_power_app/lib/app/data/repositories/game_repository.dart`
- `wings_of_power_app/lib/app/data/models/leaderboard_entry.dart`
- `wings_of_power_app/lib/app/routes/app_routes.dart`
- `wings_of_power_app/lib/app/routes/app_pages.dart`
- This task file

## Manual test (two simulators)

1. Play a fixture match to the end. Give Alex a Q2 answer and Casey a blank timeout so their kindness differs. Both phones show the same winner (higher Vs score). Rosters show student faces and nicknames.
2. Force a tie by using a debug match or by both missing every shot, if the seed can do that. Both phones omit the Winner ribbon. Neither phone crowns itself.
3. Alex taps Leaderboard. Alex’s row shows the new kindness (50 if only Q2 scored) and Alex’s avatar. Casey’s phone, opened to the same board, shows the same numbers. Blake, ineligible, can still open the board if the route is reachable from profile; Blake’s kindness is 0 and Blake is not listed as the winner of Alex’s match.
4. Back to Lobby on both phones. A second practice creates a new `matchId`. The old result does not keep adding 50 on each visit to the board.
5. Logged `match:finished` is the only source of the winner label.

## Done when

- The script passes on two simulators.
- `flutter analyze` and `flutter test` pass. Debug build passes.
- Status and Notes updated.

## Notes

-
