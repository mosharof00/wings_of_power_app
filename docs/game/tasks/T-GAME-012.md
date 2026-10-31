# T-GAME-012 — Pass, teammate wait, majority, Harmony

**Status:** Not started
**Pair:** `wings_of_power_backend/docs/tasks/T-BE-GAME-012.md`
**Phase:** 3
**Depends on:** T-GAME-011 and T-BE-GAME-012
**Plan:** `wings_of_power_app/docs/game/GAME_PLAN.md`

## Goal

On a five-person team the buzz winner can pass once, teammates wait, Q4 majority uses every vote that arrived, and Harmony can ask one teammate without showing them the answer key.

## In scope

- Pass Now enabled only when the server sends `canPass`. One tap sends `round:pass`. The passer’s options lock. A teammate’s phone becomes the answerer (“You buzzed first!” is replaced by the server’s line; if the server sends no new line, show “Your teammate passed to you”).
- Waiting states from `buzzer_and_quiz_round/Waiting state.png` and `Waiting state for same team member.png`, using `round:waiting.reason`.
- Q4: every teammate of the buzzing team sees the vote UI and 00:20. Opponents see the waiting sheet (`round_4/Vote waiting screen.png`) with counts only. Result sheet shows the winning letter.
- Harmony banner (`selected_power_banner/Quarter 3-2.png`): “Your teammate is here to help!” and **Ask for help**. That sends `power:help_request`. A teammate gets a suggest control that emits `power:help_suggest` with an option index. The buzzing phone may highlight that suggestion and still must tap the answer itself. No phone receives the correct index as part of the suggestion.

## Out of scope

- More than one pass per question.
- A second power use.
- Changing 1v1, where Pass stays disabled and Harmony still returns `NO_TEAMMATE`.

## Allowed files

- `wings_of_power_app/lib/app/modules/game/**`
- `wings_of_power_app/lib/app/data/services/game_socket_service.dart`
- This task file

## Manual test (two simulators)

Use `yarn game:queue-fixtures` so ten students are queued and the match starts. Alex and Casey may land on the same team or not. Run the script either way. The automated server test covers the exact tallies.

1. On a question, the buzz winner’s teammate sees “Your Teammate is Playing” and cannot pick an option. An opponent sees the named waiting line.
2. If Alex wins a buzz and has a teammate, Alex taps Pass Now once. Alex’s board locks. Exactly one teammate becomes the answerer. A second Pass on that question does nothing. The other simulator, if it is the opponent, never receives the answer controls.
3. Q4: when Alex’s team buzzes, every phone on that team can vote and the other team cannot. After the result, both simulators show the same “Team {label} chose {letter}”. A phone that has voted sees the classmates-waiting sheet until the server resolves. Counts on the waiting phone do not include letters.
4. If the Harmony player is on one of the two phones and buzzes in Q3, Ask for help lets the other phone suggest an option only when that phone is a teammate. The suggestion highlight appears. The buzzing player can still choose a different option. The suggest payload in the log has no `correct` field.
5. Replay a 1v1 on the two simulators afterward. Pass is disabled. Harmony does not open Ask for help.

## Done when

- The script passes on two simulators.
- `flutter analyze` and `flutter test` pass. Debug build passes.
- Status and Notes updated.

## Notes

-
