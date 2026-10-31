# T-APP-001 — Remove the Quick Cart demo

**Status:** done

**Depends on:** none

## Scope

Strip shop and boilerplate demo code so the GetX shell still runs, with the visible app name **Wings of Power**. Leave `com.example` Android applicationId and iOS bundle id unchanged (see `docs/PLAN.md` identity table). No product bundle id is written down in `docs/`; do not invent one.

Set `AppConfig.appName` to `Wings of Power`. Set Android `android:label` and iOS `CFBundleDisplayName` to `Wings of Power`.

Add `AppConfig.useMocks = true`. Remove `https://flutter.pixelstack.cloud` and `vendex-user-app`. `ApiClient` still needs a base URL string while mocks are on: use `http://localhost` and a one-line comment that the host is unset. Repositories added later must not call the network when `useMocks` is true.

Remove the commented Firebase (`meeza`) and Supabase blocks in `main.dart`.

Replace `test/widget_test.dart`. The counter test does not match this app. A small test that `AppConfig.appName` is `Wings of Power` is enough. Pumping `MyApp` needs Hive; do not keep the counter test.

After cleanup the app still starts on `Routes.SPLASH` and can open a blank home shell. Login, home, and profile modules stay as empty compiling shells for later tasks. Delete the products module and `/products`.

## Out of scope

Theme tokens (`T-APP-002`), asset pipeline (`T-APP-003`), Wings screens, bundle id / applicationId / Kotlin package changes.

## Demo removed

Modules and routes: `lib/app/modules/products/`, `Routes.PRODUCTS`.

Shop UI inside home, profile, and the three-tab `google_nav_bar` shell. Login email form copy (leave a blank `LoginView` shell).

Data: `product_repository.dart`, `products_model.dart`, dummyjson endpoints, currency extension, `enums.dart` shop constants.

Widgets: `product_layout.dart`, `view_rating_stars.dart`, `badge_icon.dart`, `simple_views.dart`, `countdown_timer_widget.dart`, `format_time.dart`, `document_upload_field.dart`, `custom_phone_field.dart`, `show_auth_dialog.dart`.

Rewrite `shimmer_loading.dart` so it does not import `flutter_staggered_grid_view`.

Packages removed from `pubspec.yaml`: `flutter_rating_bar`, `flutter_staggered_grid_view`, `badges`, `google_nav_bar`.

Demo tab SVGs (`block_*`, and `home_*` / `profile_*` once nothing references them). Keep `assets/logos/app_icon.png` (launcher icon path).

## Allowed files

- `lib/main.dart`
- `lib/app/core/config/app_config.dart`
- `lib/app/core/constants/enums.dart` (delete if empty)
- `lib/app/core/extensions/get_currency_extension.dart` (delete)
- `lib/app/core/network/api_endpoints.dart`
- `lib/app/data/repositories/app_repository_binding.dart`
- `lib/app/data/repositories/product_repository.dart` (delete)
- `lib/app/data/models/products_model.dart` (delete)
- `lib/app/routes/app_pages.dart`
- `lib/app/routes/app_routes.dart`
- `lib/app/modules/products/**` (delete)
- `lib/app/modules/home/**`
- `lib/app/modules/profile/**`
- `lib/app/modules/login/**` (shell only)
- `lib/app/modules/main_page/**`
- `lib/app/modules/splash/**` (only if a deleted import breaks it)
- `lib/app/global/layouts/product_layout.dart` (delete)
- `lib/app/global/widgets/` files named in **Demo removed**
- `pubspec.yaml`
- `android/app/src/main/AndroidManifest.xml` (`android:label` only)
- `ios/Runner/Info.plist` (`CFBundleDisplayName` only)
- `test/widget_test.dart`
- Demo SVGs under `assets/icons/` that no longer have references
- This file (Status / Notes)

## Done when

- `flutter analyze` is clean
- `flutter test` passes
- `flutter build apk --debug` succeeds, or an iOS debug build on macOS
- App launches on a simulator to the splash shell
- Visible name is Wings of Power
- Android applicationId is still `com.example.wings_of_power_app` and iOS bundle id is still `com.example.wingsOfPowerApp`

## Notes

- Visible name is Wings of Power (`AppConfig.appName`, Android `android:label`, iOS `CFBundleDisplayName`). `useMocks` is true. `domainUrl` is `http://localhost` (host unset). `projectID` is removed. Android applicationId is still `com.example.wings_of_power_app`. iOS bundle id is still `com.example.wingsOfPowerApp`.
- Login, home, and profile are empty scaffolds. `/products` and the shop module are gone. The main page shows the home shell and still confirms before exit. `changePage` stays on `MainPageController` because `HelperUtils.backToMain` calls it. Home does not call the network.
- `paginated_views.dart` still imported `flutter_staggered_grid_view` after the shop grids were removed. Its masonry branch now uses `GridView` so that package could be dropped.
- `flutter_lints` was indented under `flutter_launcher_icons`, so it was not a real dev dependency. It is one now. `constant_identifier_names` is off so `Routes.HOME` can stay. Lint infos that then showed up were cleared in `local_store_service.dart`, `helper_utils.dart`, `image_picker_helper.dart`, `cached_image.dart`, `custom_appbar.dart`, and `shimmer_loading.dart`.
- Demo tab SVGs are deleted. `lib/gen/assets.gen.dart` lists `back_arrow_icon.svg` only. `assets/sounds/.gitkeep` keeps the existing sounds pubspec entry.
- `flutter analyze` is clean. `flutter test` passed. `flutter build apk --debug` wrote `build/app/outputs/flutter-apk/app-debug.apk`. `flutter build ios --debug --simulator` wrote `Runner.app`, which launched on the iPhone 18 Pro Max simulator. The first screen is the existing white splash shell. The iOS build warned that `pubspec.yaml` has no `version:` field. That warning is outside this cleanup.
