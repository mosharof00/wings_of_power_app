# T-GAME-013 — Player and number intro

**Status:** Not started
**Pair:** `wings_of_power_backend/docs/tasks/T-BE-GAME-013.md`
**Phase:** 3
**Depends on:** T-GAME-011 and T-BE-GAME-013
**Plan:** `wings_of_power_app/docs/game/GAME_PLAN.md`

## Goal

After Start Game and before countdown, each phone shows the same sequence of cards: “Number {n}, {nickname}”. A bundled number clip plays when the file exists. This is the whole announcer (decision 10).

## In scope

- Read `jerseyNumber` from `match:found` members. Do not invent numbers on the client. If a member has no number, skip the audio and show the nickname only.
- Full-screen card, one player at a time, in the server’s `introOrder`. Same order on every phone.
- Play `assets/audio/announcer/number_{n}.m4a` (or `.mp3`) for n in 1…10 when the asset is in the pubspec. If the file is absent, the card still shows and the sequence still advances on the server clock (`deadlineAt` per card, or a single sequence deadline — follow the event).
- No other announcer lines. No buzz call, no score call, no TTS, no crowd layer.
- 1v1 plays two cards. 5v5 plays ten. Practice bot: play the human and skip the bot, unless the server includes the bot. Follow the server list either way.
- Mute switch: if the phone’s silent switch is on, still show the cards.

## Out of scope

- Recording new voice talent. Drop in files later without a code change beyond pubspec assets.
- Jumbotron play-by-play from the truncated Oct 18 spec.
- Changing match rules.

## Allowed files

- `wings_of_power_app/lib/app/modules/game/**`
- `wings_of_power_app/lib/app/data/services/game_socket_service.dart`
- `wings_of_power_app/pubspec.yaml` (audio plugin already in the app, or `audioplayers` if none exists, plus the asset folder)
- `wings_of_power_app/assets/audio/announcer/.gitkeep` if no clips are checked in
- This task file

## Manual test (two simulators)

1. Real 1v1, Alex and Casey, tap Start Game. Both phones show two cards in the same order, with the same numbers, before 3-2-1. Numbers are 1 and 2 and they do not swap between phones.
2. Kill audio assets (or run before any are added). The cards still advance and countdown still starts. Neither phone speaks a library TTS line.
3. With one sample clip present for number 1 only, both phones play it on that card and stay silent on the other number.
4. Start a 5v5 with the fixture filler. Both phones show ten cards, same order, numbers 1 through 10 each used once. Then countdown. The first question is unchanged from T-GAME-012.
5. A bot practice match does not announce a made-up name. The card list matches `match:found`.

## Done when

- The script passes on two simulators.
- `flutter analyze` and `flutter test` pass. Debug build passes.
- Status and Notes updated.

## Notes

-
