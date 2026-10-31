# T-APP-003 — Asset setup

**Status:** todo

**Depends on:** T-APP-001

## Scope

`design/assets_export/` has no images (only `.DS_Store`). `SCREEN_INVENTORY.md` names empty export folders `backgrounds/`, `book_covers/`, `characters/`, and `icons/`. This task creates the app-side folders and the generator. It does not slice the 101 screen PNGs into production art.

### Folders (under `wings_of_power_app/assets/`)

| Folder | Contents later |
|--------|----------------|
| `backgrounds/` | Sky, clouds, page backgrounds |
| `book_covers/` | Story covers |
| `characters/` | Power heroes and spot illustrations |
| `icons/` | UI icons (SVG) |
| `badges/` | The six badge marks |
| `onboarding/` | Onboarding illustrations |
| `logos/` | Already exists (`app_icon.png`). Wordmark / butterfly go here |
| `images/` | Already exists. Empty and placeholder bitmaps stay until a screen task replaces them |

Add a `.gitkeep` in each empty folder so the folder is real. Declare every folder under `flutter: assets:` in `pubspec.yaml`. Keep `assets/sounds/` as already declared.

### Naming

- `snake_case`, no spaces, no `&`
- Prefix: `bg_`, `cover_`, `hero_`, `ic_`, `badge_`, `logo_`
- Icons are SVG. Illustrations are PNG or WebP
- One file per asset. Use Flutter’s scale; do not add `@2x` copies unless a bitmap is unreadable at 1x
- Screen PNGs in `design/screens/` are references. Do not copy a full phone mockup into `assets/`

### Generated constants

`lib/gen/assets.gen.dart` already exists (FlutterGen shape, hand-checked into the repo) and `pubspec.yaml` has no generator config. Add `build_runner` and `flutter_gen_runner` as dev dependencies and a `flutter_gen` block that:

- writes `lib/gen/assets.gen.dart` (same path views already import)
- enables the `flutter_svg` integration

Regenerate with `dart run build_runner build --delete-conflicting-outputs`. After that, the file is generated: do not hand-edit it. Views use `Assets.icons.*`, `Assets.images.*`, and the new folders’ getters. `AppConfig.appLogo` string paths move to `Assets.logos.*` in this task if splash/login still compile against them.

Drop generated getters for demo SVGs deleted in `T-APP-001`.

## Screenshots

None. Later tasks name files inside these folders.

## Assets

The folders above. No new art in this task beyond `.gitkeep` and whatever already sits in `logos/` and `images/`.

## API

None.

## States

None.

## Navigation

None.

## Allowed files

- `pubspec.yaml`
- `lib/gen/assets.gen.dart` (generated output only)
- `assets/**` folders and `.gitkeep`
- `lib/app/core/config/app_config.dart` (logo path → `Assets` getter, if the shell still reads `appLogo`)
- `lib/app/modules/splash/views/splash_view.dart` and `lib/app/modules/home/views/home_view.dart` only to switch a leftover string path to `Assets`
- This file (Status / Notes)

## Done when

- `flutter analyze` is clean
- `flutter test` passes
- App runs on a simulator
- `dart run build_runner build --delete-conflicting-outputs` regenerates `lib/gen/assets.gen.dart` without a hand edit
- `pubspec.yaml` lists the folders above
- A missing Wings illustration is not replaced by copying a full screenshot into `assets/`

## Notes

-
