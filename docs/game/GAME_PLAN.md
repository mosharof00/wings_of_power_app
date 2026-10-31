# Basketball game show — build plan

`design/screens/game` is **not empty**. It has the mode select, how-to-play, hero and avatar sheets, 1v1 and 5v5 waiting rooms, countdown, quarter intros, Q1–Q4, powers, shootout, championship, round complete, team sheets, and leave. This plan follows those screens plus `docs/BRIEF.md`, `docs/DECISIONS.md`, `docs/REALTIME.md`, and the game section of `docs/API.md`. Blueprint text is concept-only and loses where a screen or a locked decision disagrees.

Paired server tasks live in `wings_of_power_backend/docs/tasks/T-BE-GAME-###.md`. App tasks live in `wings_of_power_app/docs/game/tasks/T-GAME-###.md`. Do one pair at a time. The server task lands first when the pair adds behavior.

## Authority

The Nest process is the referee. The Flutter app draws what the server sends and submits buzzes, answers, votes, passes, power uses, and shootout gestures.

- `round:question` never includes the correct index, which options are wrong, or another player’s vote.
- Scores, kindness, the buzz winner, the vote majority, and the match winner come from server events.
- The client paints the clock from `deadlineAt` and `serverNow`. It does not advance the phase when its local timer hits zero.
- A second phone on the same match must show the same phase, scores, and winner as the first. A phone on a different match must not.

Transport is Socket.io on the default namespace, JWT in the handshake, rooms `user:{userId}` and `match:{matchId}`, as in `docs/REALTIME.md`. REST queue and eligibility stay as in `docs/API.md`. One Nest process holds queues and live state in memory and writes `GameMatch` on create and finish. Do not add Redis, BullMQ timers, or a second gateway beside a new `GameGateway`. Do not hang game events on the template chat gateway.

## Order

1. **Phase 1 — playable 1v1 against a bot or a fixture.** One phone can finish four quarters. Two phones can share a `fixtureCode` and play each other on the same engine, with no public queue.
2. **Phase 2 — real 1v1 matchmaking.** Single Player waits for a second eligible student.
3. **Phase 3 — 5v5.** Multi Player waits for ten, then a random split. Pass, teammate wait, majority vote, and Harmony land here. The announcer intro lands last.

Do not start phase 2 until a fixture match can be finished on two simulators. Do not start phase 3 until two real students can finish a 1v1.

## Mode select

| What the student sees | Mode | When it is real |
|---|---|---|
| Single Player card | `ONE_V_ONE` | Phase 2. Two-slot waiting room (Player 1 / Player 2). |
| Multi Player card | `FIVE_V_FIVE` | Phase 3. Team A / Team B, ten seats. |
| Practice (no card yet) | `SINGLE` | Phase 1. One human and a bot, or two humans with the same `fixtureCode`. |

D22 records this mapping. The art does not say “1v1” or “5v5”; the waiting rooms and decision 7 do. Phase 1 may enter practice from the Single Player card only until phase 2 replaces that tap with the real queue. There is no third shipping card.

`POST /api/game/queue` body stays `{ mode }`. Phase 1 adds an optional `fixtureCode` string, accepted only when `GAME_FIXTURES=1`. T-BE-GAME-002 writes that into `docs/API.md` before coding it. Students never see the code.

## Unlock

Ineligible students get the home modal **Unlock the Game Show!** Copy: complete **2 stories or 6 chapters** and score **70%** or higher (D2). Actions: Continue Reading, close. Eligible students get the congratulations modal (Play Now, How to Play) once, then the mode select (avatar, coins, XP, Choose Hero, How to Play). Rules come from `GET /api/game/eligibility` (`eligible`, `progress`, `rules`), not from hardcoded client thresholds. Admin can change 2/6/70 later; this plan does not build the admin screen.

## How to play

Sheet from the mode select and from the congratulations modal. Five steps, from the PNG:

1. Choose the play mode. One opponent or a team.
2. Hit the red buzzer. First buzz answers. **10 seconds.** Pass once to a teammate.
3. Steal the point if the answer is wrong.
4. Every correct answer earns a ball for the shootout after the round.
5. Highest total wins. Points from all 4 rounds add up.

`GET /api/game/how-to-play` returns that copy so the sheet is not a private client string. Close dismisses the sheet.

## Power hero and avatar

Choose Power Hero is a modal on the mode select. `GET /api/heroes` and `POST /api/heroes/:id/select`. Only an unlocked hero can be selected. The blueprint names seven: Faith, Harold, Ralph, Michele, Samantha, Michael, Chi. The picker art shows eight portraits. Seed the seven. Do not invent the eighth name (OPEN_QUESTIONS, planner 11).

Change Avatar is a face picker, not a hero picker. Save calls `PATCH /api/student/profile`. Leaderboards and waiting rooms use this avatar and the student nickname (decision 5), not the hero’s name.

Header coins on the mode select are kindness. The basketball chip is XP. Both come from the server.

## Match flow

```text
eligibility → mode select → (practice | queue)
  → waiting room, if a human seat is still open
  → Start Game, or the server’s 20s auto-start once the room is full
  → countdown 3-2-1 over the room
  → for each quarter: intro card → questions → shootout for balls earned → round complete
  → results → leaderboard hook
```

Practice with a bot skips the waiting room and starts the countdown. A full human room shows **Start Game** and **Cancel** (D20). Partial rooms show **Back to Lobby** and **Explore Stories**.

Quarter cards:

| Round | Title | Blurb | Button |
|---|---|---|---|
| Q1 `Q1_WARMUP` | Warm-Up Hoops | Answer fast and earn balls for the Shootout | Open Your First Quiz |
| Q2 `Q2_DEFENSE` | Defense Round | Share your kindness. There are no wrong answers. | Read the Story |
| Q3 `Q3_HOBBY` | Hobby Hoops | Use your Power Wing once to help your team | Open Your Quiz |
| Q4 `Q4_FINALS` | Wings Final | Share your thoughts. Baskets are worth 3 points | Start Championship |

The bolt opens Team Power Wings. Before Q3 it shows **Not Available!** and Keep Playing. The X opens **Leave the match?** Stay or Leave.

### Q1 and Q3 questions

Five MCQs, progress `1/5`, four options labeled A–D. The blueprint’s “3 options” does not apply; the screens show four.

1. Everyone sees the prompt and **Buzz** (“Press first to answer”). No options yet.
2. Server picks the first legal `round:buzz`. That player sees “You buzzed first!” and the options. Teammates see “Your Teammate is Playing”. Opponents see “{name} from Team {label} is Playing”.
3. Answer window is 10s. **Next** stays locked until the server result. **Pass Now** is enabled only when the team has someone else and this question has not been passed. Passing gives the answer window to a teammate; the passer cannot then answer.
4. Server emits `round:answer_result`. Correct copy: “Correct! Well done.” Wrong copy: “Nice try!” The client does not color an option until that event.
5. Wrong answer opens one steal buzz for the other team (10s). A correct steal earns the ball. A wrong steal or a quiet window moves on.
6. No buzz in 10s moves on. Nobody earns a ball.

Q3 is the same, plus one power use per player for the whole quarter (`power_used`).

### Q2

Not a buzzer. Both sides write. Timer **00:60**. Prompt on screen is the Harold lunch scenario; the live prompt comes from the pack. Submit stays disabled until there is text. After submit, “Waiting for your classmates” if the other side is still in the window. A non-empty answer awards **+50** kindness and a shootout ball (D23). Blank or timeout awards nothing. Then **Play the Shoot**.

### Q4

Three questions, progress `1/3`. Buzz first, same as Q1. The buzzing **team** then has **20 seconds** (D9). Each connected member submits one vote. The client shows submitted counts only (`round:vote_update`), never the choices. Majority of votes received wins. The 1v1 team has one voter, so that vote is the majority (D9). Resolve early when every connected member of that team has voted. Tie or no votes: no basket. Result sheet: “Voting Results / Team {label} chose {letter}” and **See the Result!**

### Shootout and results

Each ball is one swipe. Q1–Q3 use the single-shot court. Make: “Basket Bonus +2XP”. Miss: “Oops! So Close!” and **+0 XP**. The server accepts `made` only from the shooter, inside the 60s window (REALTIME). Timeout is a miss. The bot always makes.

The Vs pills show **3 points per made basket** (Q4 intro). They are not kindness and they are not the +1 overlay.

After a quarter’s shots, round complete shows both teams’ kindness coins and XP, then **Play Next Round**. After Q4, the championship court (roster, 00:60, swipe) runs, then the winner card: **Winner - Team {label}**, both rosters, coins, XP, **Back to Lobby**. Tie: no Winner ribbon.

### Kindness and the leaderboard

Only Q2 writes kindness, and only the +50 above. On `match:finished` the server inserts `PointsLedger` rows (`kindness_amount`, `source` game, `ref` this match). `GET /api/student/leaderboard` sums that kindness and returns avatar plus nickname. The results screen offers **Leaderboard** next to Back to Lobby. The destination is the student leaderboard route. This plan does not redraw that screen if another task owns it; the hook is the ledger write plus the button. Decision 5 wins over leaderboard art that still shows characters.

## Powers (server applies, client banners)

One use per player per match, Q3 only. `power:effect` tells the client what changed. It never includes the correct index.

| Code | Banner to show | Server effect |
|---|---|---|
| `NATURE` | “Nature has a clue for you!” | Hint string from pack meta |
| `MELODY` | “You got extra time! +10s” | `deadlineAt` += 10s |
| `HARMONY` | “Your teammate is here to help!” / Ask for help | Phase 3 only. Teammate suggests an option. The buzzing player still submits. Reject with `NO_TEAMMATE` when the team size is 1. |
| `LAB` | “Science to the rescue! Two options eliminated!” | Remove two wrong indexes |
| `STORY` | “Your story clue is ready!” | Hint string from pack meta |
| `CHECKMATE` | “Smart move! One option eliminated!” | Remove one wrong index |
| `COLOR` | “Time is frozen! 10s” | `deadlineAt` += 10s |
| `PRISM` | Percent labels under the four options | Weights from pack meta, or 25/25/25/25. No weight may be 100 on the correct option. |

`selected_power_banner/Quarter 3-3.png` (“You got a hint!”) is unassigned. Do not show it until OPEN_QUESTIONS planner 12 is answered.

## Disconnect, timeout, odd counts

Use D19, D20, and D21. Short version:

- Leave is immediate. The other phones show “Player Left! {name} left this game…” and keep the current question.
- A blink shorter than 15s is not a leave. Timers do not pause.
- Rejoin with `match:snapshot`. You cannot answer a question whose deadline has passed.
- 1v1 does not start with one human in the public queue. The waiting copy is “No one is found” / “Finding your classmates”.
- 5v5 does not start short. “Only 3 classmates were found” means keep waiting. Ten players, then random 5/5. No bots in that room.
- Forfeit and cancel rules are D19. Kindness already saved is not clawed back.

## Announcer

Decision 10 puts this **in scope**, and only this: introduce each player and their number. No play-by-play, no color commentary, no TTS stack, no crowd ducking, no per-name wav pipeline from the truncated Oct 18 spec.

The server assigns `jerseyNumber` at seat time (1…2 or 1…10) and sends it on `match:found` and the snapshot. T-BE-GAME-013 adds that field to `docs/REALTIME.md` before coding. The client shows a card, “Number {n}, {nickname}”, and plays a bundled clip for that number when the file exists. Missing audio still shows the card. Play the sequence once, after Start Game and before the countdown. Both phones must show the same order.

## Fixture pack

Phase 1 seeds one pack with the screen prompts so a match is playable before the teacher game-pack CMS (that CMS is P1 and is not in these tasks):

- Q1, five MCQs. First prompt: “A classmate drops their books. What’s the kind thing to do?” Options: Walk past / Help them to pick / Laugh / Take Photo. Correct is Help them to pick. The other four are hobby MCQs with a stored correct index.
- Q2, one free-text: the Harold lunch prompt.
- Q3, five MCQs. Include “Why might learning to play the violin be a rewarding hobby?” and the reading-as-a-hobby question. Each hint-capable question has `meta_json.hint` that is not the answer text.
- Q4, three MCQs. First: “What is one benefit of reading books?” Correct letter A on the voting screen’s option text (“Build imagination and learn new things”).

The client never receives those indexes.

## Task index

| Pair | Phase | App | Server | Proves |
|---|---|---|---|---|
| 001 | 1 | [T-GAME-001](tasks/T-GAME-001.md) | [T-BE-GAME-001](../../../wings_of_power_backend/docs/tasks/T-BE-GAME-001.md) | Lock, celebration, mode select, how to play |
| 002 | 1 | [T-GAME-002](tasks/T-GAME-002.md) | [T-BE-GAME-002](../../../wings_of_power_backend/docs/tasks/T-BE-GAME-002.md) | Hero, avatar, bot match, fixture pair, socket snapshot |
| 003 | 1 | [T-GAME-003](tasks/T-GAME-003.md) | [T-BE-GAME-003](../../../wings_of_power_backend/docs/tasks/T-BE-GAME-003.md) | Countdown, intros, Q1 buzz, answer, steal |
| 004 | 1 | [T-GAME-004](tasks/T-GAME-004.md) | [T-BE-GAME-004](../../../wings_of_power_backend/docs/tasks/T-BE-GAME-004.md) | Shootout, Vs score, XP, round complete |
| 005 | 1 | [T-GAME-005](tasks/T-GAME-005.md) | [T-BE-GAME-005](../../../wings_of_power_backend/docs/tasks/T-BE-GAME-005.md) | Q2 text and +50 kindness |
| 006 | 1 | [T-GAME-006](tasks/T-GAME-006.md) | [T-BE-GAME-006](../../../wings_of_power_backend/docs/tasks/T-BE-GAME-006.md) | Q3 powers except Harmony |
| 007 | 1 | [T-GAME-007](tasks/T-GAME-007.md) | [T-BE-GAME-007](../../../wings_of_power_backend/docs/tasks/T-BE-GAME-007.md) | Q4 20s vote; one voter is the majority |
| 008 | 1 | [T-GAME-008](tasks/T-GAME-008.md) | [T-BE-GAME-008](../../../wings_of_power_backend/docs/tasks/T-BE-GAME-008.md) | Results, ledger, leaderboard hook |
| 009 | 2 | [T-GAME-009](tasks/T-GAME-009.md) | [T-BE-GAME-009](../../../wings_of_power_backend/docs/tasks/T-BE-GAME-009.md) | Public 1v1 queue and waiting room |
| 010 | 2 | [T-GAME-010](tasks/T-GAME-010.md) | [T-BE-GAME-010](../../../wings_of_power_backend/docs/tasks/T-BE-GAME-010.md) | Leave, disconnect, reconnect, forfeit |
| 011 | 3 | [T-GAME-011](tasks/T-GAME-011.md) | [T-BE-GAME-011](../../../wings_of_power_backend/docs/tasks/T-BE-GAME-011.md) | 5v5 lobby, odd counts, random split |
| 012 | 3 | [T-GAME-012](tasks/T-GAME-012.md) | [T-BE-GAME-012](../../../wings_of_power_backend/docs/tasks/T-BE-GAME-012.md) | Pass, teammate wait, majority, Harmony |
| 013 | 3 | [T-GAME-013](tasks/T-GAME-013.md) | [T-BE-GAME-013](../../../wings_of_power_backend/docs/tasks/T-BE-GAME-013.md) | Player-and-number announcer only |

## Not in these tasks

- Parent anything.
- Teacher or admin game-pack CMS, admin match history, admin eligibility editor.
- Gabriel, in-game Safe Space, and `safespace:*` (D5 and D14 stay as written; no calm-space PNG in this folder).
- Full announcer spec (play-by-play, TTS, crowd, substitutions).
- Redis, horizontal scale, spectators, cross-school matching.
- Replacing GetX, Dio, or the Nest module layout.
- Using template `User.points` as kindness.

## How to pick up a task

1. Read this file, the paired server task, and the screens named in the task.
2. Touch only the allowed files, plus the task’s Status and Notes when done.
3. Contract edits go through `docs/API.md`, `docs/REALTIME.md`, or `docs/DATABASE.md` first, and only when the task names the edit.
4. Run the manual script on **two simulators or two devices** before marking the pair done.
5. App validation, from `wings_of_power_app/`: `flutter analyze`, `flutter test`, and `flutter build apk --debug` (or iOS if that is the machine you have).
6. Server validation, from `wings_of_power_backend/` with yarn: `yarn lint`, `yarn test`, `yarn test:e2e`, `yarn build`.

## Manual-test accounts

Seed two active students, Alex and Blake, plus the fixture pack.

- Alex is eligible (progress meets 2/6/70).
- Blake is ineligible (progress all zero).
- A third student, Casey, is eligible and is used when a task needs a leftover queue seat.

Nicknames and avatars must be distinct so waiting-room slots are obvious. Passwords stay in the local seed, not in git.
