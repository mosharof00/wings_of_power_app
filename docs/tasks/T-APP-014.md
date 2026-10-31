# T-APP-014 — Quiz round

**Status:** todo

**Depends on:** T-APP-012

## Scope

Chapter complete, chapter comprehension quiz, quiz result, and mid-chapter checkpoint.

`student.chapter_complete`, `student.chapter_quiz`, `student.chapter_quiz_result`, `student.checkpoint_quiz`.

### Chapter complete

Both files are the same step (two exports):

- `story_description_&_chapters/new_student/Story Completed.png`
- `story_quiz_round/each_chapter_questions/Story Completed.png`

Copy: take the quiz / unlock a power wing. Actions: Take Quiz Now!, Back to Home.

### Chapter quiz

Gabriel host card, multiple choice, star progress, speaker, close.

| PNG | State |
|-----|--------|
| `Comprehension Quiz.png` | Unanswered |
| `Comprehension Quiz-1.png` | Selected |
| `Comprehension Quiz-2.png` | Correct |
| `Comprehension Quiz-3.png` | Wrong |
| `Comprehension Quiz-4.png` | Last question |
| `Leave questions.png` | Leave modal: Keep Going / Leave |

Check Answer, then Next. Last question: See Result.

Speaker toggles the question read-aloud only if the device TTS the app already has is enough (`flutter_tts` is not a dependency). The icon is drawn. If there is no plugin, the button shows and does not add a new package in this task; Notes say TTS is unwired. Do not add a Gabriel motivation popup (no PNG, D14).

### Results

| PNG | Score on the frame | Points |
|-----|--------------------|--------|
| `Quiz Completed.png` | 3/5 | +6 |
| `Quiz Completed-1.png` | 1/5 | +2 |
| `Quiz Completed-2.png` | 5/5 | +10 |

The progress bar is drawn at 10% on all three. That is a known design bug (`SCREEN_INVENTORY`, open questions). Match the PNG, including that bar. Do not replace it with a computed percent. Actions: Next Chapter, Back to Story. Play Again is on the non-perfect frames and absent on the perfect frame.

Points on the result come from `POST /api/attempts/:id/complete`.

### Checkpoint

| PNG | State |
|-----|--------|
| `Quiz.png` | Unanswered |
| `Quiz-1.png` | Selected |
| `Quiz-2.png` | True / false |
| `Write Answer.png` | Success modal. The inventory says this frame is the success modal, not a free-text composer. Build the modal that is drawn. Do not add a free-text checkpoint |
| `1st time wrong answer.png` | Hint, Try Again! |
| `2nd time wrong answer.png` | Reveal, Keep Reading |

Submit on the first answer. First wrong → hint. Second wrong → reveal and Keep Reading, which returns to the reader page.

Flow: `GET` quiz (do not show the correct option before submit) → `POST /api/quizzes/:quizId/attempts` → `POST /api/attempts/:id/answers` → `POST /api/attempts/:id/complete`.

Checkpoint: `GET /api/chapters/:chapterId/checkpoint`, then the same attempt/answer calls.

Mock until `T-BE-013`. Fixtures for 3/5, 1/5, and 5/5 so each result PNG can be opened.

## Screenshots

Chapter complete: the two `Story Completed.png` paths above.

`design/screens/student/story_quiz_round/each_chapter_questions/`:

- `Comprehension Quiz.png`
- `Comprehension Quiz-1.png`
- `Comprehension Quiz-2.png`
- `Comprehension Quiz-3.png`
- `Comprehension Quiz-4.png`
- `Leave questions.png`
- `Quiz Completed.png`
- `Quiz Completed-1.png`
- `Quiz Completed-2.png`

`design/screens/student/story_quiz_round/quick_checkpoint_questions/`:

- `Quiz.png`
- `Quiz-1.png`
- `Quiz-2.png`
- `Write Answer.png`
- `1st time wrong answer.png`
- `2nd time wrong answer.png`

## Assets

- `assets/characters/gabriel_host.png` — host card
- `assets/icons/ic_speaker.svg`
- Star / wing marks if they are not plain icons: `assets/icons/ic_quiz_star.svg`

## API

Mock until `T-BE-013`:

- `GET /api/chapters/:chapterId/quiz`
- `GET /api/chapters/:chapterId/checkpoint`
- `POST /api/quizzes/:quizId/attempts`
- `POST /api/attempts/:id/answers` — `questionId`, `optionId`; response includes correct/hint
- `POST /api/attempts/:id/complete` — score and points

Chapter complete’s complete call is `T-APP-012` (`T-BE-012`). This screen only navigates.

## States

Listed in the tables above, plus the leave modal and the three result scores.

## Navigation

- In: end of reading or listening → chapter complete. Checkpoint hook from the reader. Quiz row on a chapter (`T-APP-011`) → quiz, skipping the complete card when the chapter is already done
- Take Quiz Now! → first question
- Back to Home → home tab
- Close / Leave → leave modal. Keep Going stays. Leave → story chapters
- See Result → result
- Next Chapter → next chapter reading, or story chapters if there is no next chapter
- Back to Story → story chapters
- Play Again → new attempt (not shown on 5/5)
- Checkpoint Keep Reading → reader
- A badge-unlock modal after a perfect score is `T-APP-015` if the complete payload includes a new badge. This task navigates there only when that payload is present; it does not build the badge screens

## Allowed files

- `lib/app/modules/quiz/**` (new)
- `lib/app/data/repositories/quiz_repository.dart`
- `lib/app/data/models/quiz_models.dart`
- `lib/app/data/mocks/quizzes.dart`
- `lib/app/data/repositories/app_repository_binding.dart`
- `lib/app/core/network/api_endpoints.dart`
- `lib/app/modules/reader/**` (checkpoint hook only)
- `lib/app/routes/app_pages.dart`
- `lib/app/routes/app_routes.dart`
- Assets named above
- This file (Status / Notes)

## Done when

- `flutter analyze` is clean
- `flutter test` passes
- Runs on a simulator
- Every screenshot in this task matches at 375×812, including the 10% result bar as drawn
- Correct option is hidden until Check Answer / Submit
- Play Again is absent on the 5/5 frame
- No free-text checkpoint and no Gabriel popup

## Notes

-
