# T-APP-009 — Character choose and unlock

**Status:** todo

**Depends on:** T-APP-007, T-APP-004

## Scope

First hero during signup, and the later roster reached from profile “My Power Hero” / “See All Power Heroes”.

Signup screens (`student.hero_grid`, `student.hero_ready`, `student.hero_detail`):

- Grid shows some heroes locked and one selected. Step label on the PNG stays as printed (`2/2` on the grid). Do not renumber it.
- Detail: Michele - Artist, Power: Color Shot, plus the confirm modal (first character unlock rules) with Yes / Go Back.
- `Character showing.png`: “Michele is ready!” and the quote. The PNG has no button. Build that card. Do not add a CTA. Notes must say the flow stops on this frame until design adds a control (`SCREEN_INVENTORY` row `student.hero_ready`).

After a successful select, call `GET /api/auth/me`. `PENDING` → account verification (`T-APP-007`). `ACTIVE` → home. With mocks, signup select returns `PENDING` so the dead end can be checked, and a debug/mock toggle in the controller (not a new screen) can return `ACTIVE` so home can be opened.

Later roster (`student.hero_roster`, `student.power_hero`):

- Profile strip of unlocked heroes, “See All Power Heroes”
- Partial unlock, all unlocked, locked modal, Faith detail, and the per-hero sheets `Choose Character.png` through `Choose Character-12.png`
- Locked copy: complete 2 stories. Primary actions on those frames: Choose hero, Explore Stories
- Unlock rule on the PNG is the copy. Do not invent a second rule. Eligibility numbers for the game show stay in `T-APP-010`

Select endpoint for a hero the student is allowed to pick: `POST /api/heroes/:id/select` (`MODULE_MAP`, API section 6). `POST /api/auth/student/select-hero` is the same action in the auth-flow list. Call the section 6 path once. Do not call both.

Mock until `T-BE-014` for heroes, and `T-BE-010` for `GET /api/auth/me`.

## Screenshots

Signup:

- `design/screens/student/authentication_&_character_choose/Character choose.png`
- `design/screens/student/authentication_&_character_choose/Character showing.png`
- `design/screens/student/authentication_&_character_choose/Choose Character.png`
- `design/screens/student/authentication_&_character_choose/Choose Character-1.png` — confirm modal

Roster and profile strip:

- `design/screens/student/profile/Power Hero.png`
- `design/screens/student/wings_of_power_basketball_team/Character.png`
- `design/screens/student/wings_of_power_basketball_team/All Character unlock.png`
- `design/screens/student/wings_of_power_basketball_team/Character Unlocking.png`
- `design/screens/student/wings_of_power_basketball_team/Choose Character.png`
- `design/screens/student/wings_of_power_basketball_team/Choose Character-1.png`
- `design/screens/student/wings_of_power_basketball_team/Choose Character-2.png`
- `design/screens/student/wings_of_power_basketball_team/Choose Character-3.png`
- `design/screens/student/wings_of_power_basketball_team/Choose Character-4.png`
- `design/screens/student/wings_of_power_basketball_team/Choose Character-5.png`
- `design/screens/student/wings_of_power_basketball_team/Choose Character-6.png`
- `design/screens/student/wings_of_power_basketball_team/Choose Character-7.png`
- `design/screens/student/wings_of_power_basketball_team/Choose Character-8.png`
- `design/screens/student/wings_of_power_basketball_team/Choose Character-9.png`
- `design/screens/student/wings_of_power_basketball_team/Choose Character-10.png`
- `design/screens/student/wings_of_power_basketball_team/Choose Character-11.png`
- `design/screens/student/wings_of_power_basketball_team/Choose Character-12.png`

The basketball folder here is the hero roster, not the game show.

## Assets

`assets/characters/hero_<slug>.png` for each hero on the grid and the sheets (Faith, Michele, and the others shown). Slug from the name on the sheet, `snake_case`. Placeholder portrait until export art exists.

## API

Mock until `T-BE-014`:

- `GET /api/heroes` — roster and locked flags
- `POST /api/heroes/:id/select`

Mock until `T-BE-010`:

- `GET /api/auth/me` after the first select

## States

- First-run grid, one hero selected, others locked
- Michele detail
- Confirm modal: Yes / Go Back
- “Michele is ready!” with no button
- Power Hero strip, three unlocked (`Power Hero.png`)
- Roster partial unlock, all unlocked, locked modal
- One sheet per `Choose Character*.png` in the basketball-team folder

## Navigation

- In: real-name Continue (`T-APP-007`); profile “My Power Hero” (`T-APP-017`)
- Back on the grid → real name
- Choose Michele → confirm modal
- Go Back → detail
- Yes → select, then the ready card
- Ready card: no outgoing control
- See All Power Heroes → roster
- Explore Stories → story library (`T-APP-011`)
- Choose on an unlocked hero → `POST` select and return to the Power Hero strip

## Allowed files

- `lib/app/modules/heroes/**` (new)
- `lib/app/data/repositories/hero_repository.dart`
- `lib/app/data/models/hero_models.dart`
- `lib/app/data/mocks/heroes.dart`
- `lib/app/data/repositories/app_repository_binding.dart`
- `lib/app/core/network/api_endpoints.dart`
- `lib/app/routes/app_pages.dart`
- `lib/app/routes/app_routes.dart`
- `assets/characters/hero_*.png`
- This file (Status / Notes)

## Done when

- `flutter analyze` is clean
- `flutter test` passes
- Runs on a simulator
- Each screenshot listed above matches at 375×812
- Ready card has no added button
- Locked heroes do not call select (403 path stays unused for them)
- No game-show screen is built

## Notes

-
