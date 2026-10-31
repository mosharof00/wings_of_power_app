# T-APP-003 — Asset setup

**Status:** done

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

- Empty folders with `.gitkeep`: `assets/backgrounds/`, `assets/badges/`, `assets/book_covers/`, `assets/characters/`, `assets/onboarding/`. `assets/icons/`, `assets/images/`, `assets/logos/`, and `assets/sounds/` already existed. No screen PNG was copied in.
- `pubspec.yaml` lists those nine folders. Dev dependencies: `build_runner` and `flutter_gen_runner`. `flutter_gen` writes `lib/gen/assets.gen.dart` with the `flutter_svg` integration, and excludes `**/.gitkeep` so placeholder files are not getters.
- `dart run build_runner build --delete-conflicting-outputs` regenerated the file. Current `build_runner` prints that `--delete-conflicting-outputs` is ignored; the generator still overwrote `assets.gen.dart`. Do not hand-edit it. Re-run the generator after adding a file.
- Generated getters today: `Assets.icons.backArrowIcon` (`SvgGenImage`), `Assets.images.emptyBox`, `Assets.images.placeholderImage`, `Assets.logos.appIcon`. Empty folders get a class only after a real PNG, WebP, or SVG is added.
- Naming for later files: `snake_case`; prefixes `bg_`, `cover_`, `hero_`, `ic_`, `badge_`, `logo_`. Icons are SVG. Illustrations are PNG or WebP. One file per asset. No `@2x` copies unless a bitmap is unreadable at 1x.
- `AppConfig.appLogo` and `AppConfig.splashLogo` are `Assets.logos.appIcon.path`. Splash still loads that path. Home has no asset string. `custom_icon_button.dart` now passes `Assets.icons.backArrowIcon.path` because the SVG integration returns `SvgGenImage`, not a `String`. That file is outside the allowed list; the one-line change is what keeps `flutter analyze` clean.
- `flutter analyze`: no issues. `flutter test`: passed. iPhone 18 Pro Max launched, guest splash finished, and the login scaffold showed with no missing-asset error.
