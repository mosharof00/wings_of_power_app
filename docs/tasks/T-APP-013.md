# T-APP-013 — Listening mode

**Status:** done

**Depends on:** T-APP-012

## Scope

Listen mode of `student.reader` (`Listening.png`), in the reader module from `T-APP-012`.

- Same chapter shell as reading
- Read / Listen toggle with Listen selected
- Audio scrubber, seek, pause / play
- Previous and next (page or track, whichever the PNG shows)
- `PUT` progress with `mode` set to the listen value the API field accepts (`mode` on `PUT /api/stories/:id/progress`)
- Finishing the chapter uses the same complete call and chapter-complete route as reading

Audio URL comes from `GET /api/stories/:id/chapters/:chapterId`. Playback can use the Flutter SDK audio session only if a plugin is already in `pubspec.yaml`. None is. Add one plugin in this task (`just_audio` or `audioplayers` — pick `just_audio`) and wire play, pause, and seek. Mock until `T-BE-012`: a short silent or bundled clip at `assets/sounds/chapter_sample.m4a` is optional; the scrubber must still move in the mock when no file is shipped, using a timer, so the screen can be checked without a network file.

Do not build a separate Audio Books catalog. That home tile has no screen (D14).

## Screenshots

- `design/screens/student/story_description_&_chapters/new_student/Listening.png`

## Assets

- `assets/sounds/chapter_sample.m4a` only if a real clip is added. A timer-driven scrubber is enough for the screenshot check
- Reader art already added in `T-APP-012`

## API

Mock until `T-BE-012`:

- `GET /api/stories/:id/chapters/:chapterId` — `audio` url plus pages
- `PUT /api/stories/:id/progress` — `mode` listen
- `POST .../chapters/:chapterId/complete` when the chapter audio finishes

## States

- Listen selected
- Playing (pause icon)
- Paused (play icon)
- Scrubber at the start, middle, and end
- Loading audio (shared loading)
- Read toggle returns to `T-APP-012`

## Navigation

- In: Listen on the story description (`T-APP-011`); Read/Listen toggle from reading
- Read → reading route, same chapter
- Back → story chapters
- Finished → chapter complete (`T-APP-014`)

## Allowed files

- `lib/app/modules/reader/**`
- `lib/app/data/repositories/story_repository.dart`
- `lib/app/data/models/story_models.dart`
- `lib/app/data/mocks/chapter_pages.dart`
- `pubspec.yaml` (audio plugin only)
- `assets/sounds/**` if a sample clip is added
- This file (Status / Notes)

## Done when

- `flutter analyze` is clean
- `flutter test` passes
- Runs on a simulator
- `Listening.png` matches at 375×812
- Play, pause, and seek update the scrubber
- No Audio Books catalog screen

## Notes

- Added `just_audio: ^0.9.46` to `pubspec.yaml` and resolved dependencies with `flutter pub get`.
- Implemented Listening mode matching `story_listening_mode.png`:
  * Top bar with circular back button and Read / Listen toggle pill (switching to Read updates view in-place).
  * Center story artwork / cover thumbnail card with orange border and page body text.
  * Added `AudioPlayerControlBox` at bottom with elapsed and remaining time labels (`03:16` / `12:48`), interactive scrubber bar (seeking via tap & drag), previous/rewind, replay 10s, play/pause circle button, forward 10s, and next/skip controls.
- Updated `ReaderController`:
  * Audio playback support using `just_audio` with seamless timer fallback for mock / offline environments so the scrubber advances even without network audio file.
  * Play, pause, seek, 10s forward/backward skips, previous rewind/page turn, and next chapter complete.
  * Progress reporting via `PUT /api/stories/:id/progress` with `mode: 'listen'`.
  * Chapter complete triggers `POST /api/stories/:id/chapters/:chapterId/complete` and displays `ReaderCompletedView`.
- Added standalone `StoryListeningView` in `lib/app/modules/reader/views/story_listening_view.dart`.
- Added audio sample fixture at `assets/sounds/chapter_sample.m4a` and updated `ChapterPagesMock` fixtures.
- Validated: `flutter analyze` and `flutter test` both pass cleanly.
