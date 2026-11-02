# T-APP-011 — Story library, description, and chapters

**Status:** done

**Depends on:** T-APP-010, T-APP-004

## Scope

`student.story_library`, `student.story_details`.

Library is the book tab. It shows search, category filters, age filters, and covers. Categories on the PNGs: Kindness, Courage, Cyberbullying, Friendship. Age state that exists as a PNG: 6–9 (`Age group 6-9.png`). Decision 2 also names 10–13 and adults. Draw the chips that appear on these PNGs. When the API returns another `ageGroup`, the same filter control can select it. Do not invent a 14+ chip; the “14+” vs adults clash is already an open question.

Description and chapter list, three variants:

- New student — description, chapters with locks
- Returning student — progress on chapters
- Retake — chapter list with Quiz links (`retake_quiz/Story Chapters.png`)

Start Reading / Continue Reading opens reading mode (`T-APP-012`). A Listen entry on the description opens listening mode (`T-APP-013`) when that control is on the PNG. Quiz on a chapter row opens the chapter quiz (`T-APP-014`) for a chapter that already has a quiz available (returning / retake). Locked chapters do not open.

`Loading State.png` in this folder is the reader loader; `T-APP-012` builds it. This task uses the shared loading widget for the library fetch.

Mock until `T-BE-012`. Fixtures need one new-student story (locked later chapters), one in-progress story, and one retake story. Include *City of Thieves* and *The Ties That Bind Us* in the popular/library fixture because those titles are on `Home-1.png` and named in `docs/BRIEF.md`. Cover files can be placeholders.

## Screenshots

- `design/screens/student/story_description_&_chapters/new_student/Story Library.png`
- `design/screens/student/story_description_&_chapters/new_student/Filter/Kindness.png`
- `design/screens/student/story_description_&_chapters/new_student/Filter/Kindness/Age group 6-9.png`
- `design/screens/student/story_description_&_chapters/new_student/Story Description.png`
- `design/screens/student/story_description_&_chapters/new_student/Story Chapters.png`
- `design/screens/student/story_description_&_chapters/returning_student/Story Description.png`
- `design/screens/student/story_description_&_chapters/returning_student/Story Chapters.png`
- `design/screens/student/story_description_&_chapters/retake_quiz/Story Chapters.png`

## Assets

- `assets/book_covers/cover_city_of_thieves.png`
- `assets/book_covers/cover_the_ties_that_bind_us.png`
- `assets/book_covers/cover_the_golden_pearl.png` (home popular card)
- Category art: `assets/images/category_kindness.png`, `category_courage.png`, `category_cyberbullying.png`, `category_friendship.png`

## API

Mock until `T-BE-012`:

- `GET /api/stories` — query `category`, `ageGroup`, `search`, `page`, `perPage`
- `GET /api/stories/:id` — detail, chapters, progress

## States

- All categories
- Kindness filter
- Kindness + age 6–9
- Search with no matches (shared empty state)
- Library loading
- New description and locked chapters
- Returning description and chapter progress
- Retake chapters with Quiz
- Story detail error

## Navigation

- In: book tab; home See all / Start Reading / Continue / cover; hero roster Explore Stories
- Cover → description
- Chapters section on the description (the chapter PNGs are that story’s chapter list)
- Start / Continue Reading → `T-APP-012`
- Listen, when the control is on the description PNG → `T-APP-013`
- Quiz on an available chapter → `T-APP-014`
- Back → library or home, matching the back control on the PNG

## Allowed files

- `lib/app/modules/stories/**` (new)
- `lib/app/data/repositories/story_repository.dart`
- `lib/app/data/models/story_models.dart`
- `lib/app/data/mocks/stories.dart`
- `lib/app/data/repositories/app_repository_binding.dart`
- `lib/app/core/network/api_endpoints.dart`
- `lib/app/modules/main_page/**` (book tab)
- `lib/app/routes/app_pages.dart`
- `lib/app/routes/app_routes.dart`
- Assets named above
- This file (Status / Notes)

## Done when

- `flutter analyze` is clean
- `flutter test` passes
- Runs on a simulator
- Each screenshot above matches at 375×812
- Filters change the list via the stories query
- Locked chapters do not open the reader

## Notes

- Implemented Story Library (`StoryLibraryView`), Story Details (`StoryDetailsView`), and components matching 375×812 designs.
- Handled all three story details variants: new student (locked chapters), returning student (progress bar & completed checkmark), and retake quiz (chapter rows with Quiz links).
- Implemented category and age group filter pills and modal sheets, supporting section row grouping and 2-column grid view when both filters are active.
- Added search field toggling with shared empty state (`ShowEmptyResult`) on empty search results.
- Added mock stories fixtures with "City of Thieves", "The Ties That Bind Us", "The Golden Pearl Book 1", "The Golden Pearl Book 2", and retake story.
- Added story API endpoints and repository with `useMocks` support.
- Registered `IStoryRepository` in `AppRepositoryBinding` and wired book tab in `MainPageView` to `StoryLibraryView`.
- Added stub routes for T-APP-012 (`STORY_READER`), T-APP-013 (`STORY_LISTENING`), and T-APP-014 (`CHAPTER_QUIZ`).
- Verified locked chapters prevent opening reader and display notification.
- Validated with `flutter analyze` (clean) and `flutter test` (all tests passed).
