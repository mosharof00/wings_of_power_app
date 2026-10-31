# T-APP-012 — Reading mode

**Status:** todo

**Depends on:** T-APP-011

## Scope

Read mode of `student.reader`, plus the reader loading frame.

- Chapter title, page image, body, page index
- Read / Listen toggle. Listen switches to `T-APP-013` (that task paints the audio UI; this task’s toggle calls that route)
- Previous and next page
- `PUT /api/stories/:id/progress` with `chapterId`, `pageNumber`, `percent`, `mode: read` when the page changes
- Last page of the chapter → chapter complete (`T-APP-014`, `Story Completed.png`), after `POST /api/stories/:id/chapters/:chapterId/complete`

Loading: `Loading State.png` while the chapter payload is in flight. Use the shared loading widget, laid out like that PNG.

Mock until `T-BE-012`. Fixture: a short chapter (a few pages) so next/previous and the last page can be checked.

Checkpoint questions can sit between pages. The checkpoint UI is `T-APP-014`. This task leaves a hook: if the chapter payload says a checkpoint is due on this page, push the checkpoint route. Until 014 exists, the hook can no-op.

## Screenshots

- `design/screens/student/story_description_&_chapters/new_student/Reading.png`
- `design/screens/student/story_description_&_chapters/new_student/Loading State.png`

## Assets

Page images from the API (`url` on each page). Local fixture pages:

- `assets/book_covers/page_sample_1.png`
- `assets/book_covers/page_sample_2.png`

## API

Mock until `T-BE-012`:

- `GET /api/stories/:id/chapters/:chapterId` — pages
- `PUT /api/stories/:id/progress` — `chapterId`, `pageNumber`, `percent`, `mode`
- `POST /api/stories/:id/chapters/:chapterId/complete` — when the last page is passed

## States

- Loading
- First page (previous disabled)
- Middle page
- Last page (advancing opens chapter complete)
- Read selected on the Read/Listen control
- Failed chapter fetch (shared error, retry)

## Navigation

- In: Start / Continue Reading from `T-APP-011`
- Listen → `T-APP-013` with the same story and chapter ids
- Back → story chapters
- End of chapter → `T-APP-014` chapter-complete route

## Allowed files

- `lib/app/modules/reader/**` (new)
- `lib/app/data/repositories/story_repository.dart`
- `lib/app/data/models/story_models.dart`
- `lib/app/data/mocks/chapter_pages.dart`
- `lib/app/core/network/api_endpoints.dart`
- `lib/app/routes/app_pages.dart`
- `lib/app/routes/app_routes.dart`
- `assets/book_covers/page_sample_1.png`
- `assets/book_covers/page_sample_2.png`
- This file (Status / Notes)

## Done when

- `flutter analyze` is clean
- `flutter test` passes
- Runs on a simulator
- `Reading.png` and `Loading State.png` match at 375×812
- Page changes send progress (or the mock records the body)
- The last page opens chapter complete and does not start the quiz by itself

## Notes

-
