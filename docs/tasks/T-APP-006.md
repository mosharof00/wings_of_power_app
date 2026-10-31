# T-APP-006 — Welcome, class code, and verification states

**Status:** done

**Depends on:** T-APP-005

## Scope

`student.welcome`, `student.join_class`, `student.join_wrong_code`, `student.join_expired_code`, `student.join_success`.

`Role Selection.png` is the empty class-code screen. There is no role picker on it.

Code entry is 6 digits, sent as `{ code }` to `POST /api/auth/student/join-code`.

| Result | Screen |
|--------|--------|
| 200 `{ className, teacherName, classId }` | Joined-class success. Copy uses `className` and `teacherName` (the PNG reads “Joined Grade 5, Ms. Smith Class!”) |
| 404 wrong code | “Hmm, that code doesn’t look right!” |
| 422 expired | “This code isn’t working anymore.” |

Hold `classId` and `code` in the join controller for `T-APP-007`’s register call.

Mock until `T-BE-010`. Fixture: code `123456` succeeds as Grade 5 / Ms. Smith; `000000` is expired; anything else is wrong. Those three codes exist so the three frames can be opened on a simulator.

## Screenshots

- `design/screens/student/authentication_&_character_choose/Login.png` — Log In filled
- `design/screens/student/authentication_&_character_choose/With code.png` — Join with Class Code filled
- `design/screens/student/authentication_&_character_choose/Role Selection.png` — empty code
- `design/screens/student/authentication_&_character_choose/Code verification.png` — code filled
- `design/screens/student/authentication_&_character_choose/Wrong Code.png`
- `design/screens/student/authentication_&_character_choose/Expired code.png`
- `design/screens/student/authentication_&_character_choose/Code verificaiton successfull message.png` (filename typo is the real file)

## Assets

- `assets/characters/welcome_heroes.png` — group on the welcome screen
- `assets/backgrounds/bg_auth_sky.png` — shared auth sky if it is the same as splash; otherwise reuse `bg_splash_sky.png`

## API

Mock until `T-BE-010`:

- `POST /api/auth/student/join-code` `{ code }` → `{ className, teacherName, classId }`
- Errors: 404 wrong, 422 `EXPIRED`

## States

- Welcome, Log In emphasis (`Login.png`)
- Welcome, Join with Class Code emphasis (`With code.png`)
- Code empty
- Code filled (Join Class enabled)
- Wrong code
- Expired code
- Joined class

## Navigation

- In: onboarding Skip / Get Started; logout (`T-APP-017`); “Already Joined? Login Here” is the reverse link from the code screen
- Log In → login route (`T-APP-008`)
- Join with Class Code → code screen
- Try Again! → empty code screen
- Ok, Got it! → empty code screen
- Set Up your Profile → credentials (`T-APP-007`)
- Already Joined? Login Here → login route

## Allowed files

- `lib/app/modules/welcome/**` (new)
- `lib/app/modules/join_class/**` (new)
- `lib/app/data/repositories/auth_repository.dart` (add `joinCode`; keep the existing login method compiling)
- `lib/app/data/models/auth_models/**`
- `lib/app/data/mocks/join_code.dart`
- `lib/app/core/network/api_endpoints.dart` (join-code path only)
- `lib/app/routes/app_pages.dart`
- `lib/app/routes/app_routes.dart`
- Assets named above
- This file (Status / Notes)

## Done when

- `flutter analyze` is clean
- `flutter test` passes
- Runs on a simulator
- Each screenshot above matches at 375×812, including both welcome button states
- `123456` / `000000` / other codes open success, expired, and wrong
- No role-picker UI

## Notes

- Welcome opens with Log In filled (`Login.png`). `Get.arguments == WelcomeEmphasis.join` shows Join with Class Code filled (`With code.png`). Both buttons navigate on one tap: Log In → `/login` (T-APP-008), Join with Class Code → `/join-class`.
- `Role Selection.png` is the empty 6-digit code screen. There is no role picker. The system number pad is the keyboard. Join Class stays disabled until 6 digits, then the pad dismisses.
- Mock until T-BE-010, and the repository does not call the network while `AppConfig.useMocks` is true. `123456` → Grade 5 / Ms. Smith / `classId` `grade-5-ms-smith`. `000000` → 422 expired. Any other code → 404 wrong.
- `JoinClassController` keeps `classId` and the code, and “Set Up your Profile” also passes them as arguments to `/account-setup`. That route is a blank `Scaffold` until T-APP-007.
- Try Again and Ok, Got it return to the empty code screen. Already Joined? Login Here → `/login`.
- Assets: `assets/characters/welcome_heroes.png`, `assets/backgrounds/bg_auth_sky.png` (flat sky gradient, not the splash clouds). Wrong and expired share `assets/characters/hero_code_error.png` so those frames match; the success rays are drawn, not an image.
- Checked on the iPhone 18 Pro Max: both welcome button states, empty code with the pad, filled code, wrong, expired, and joined class.
- `flutter analyze` clean. `flutter test`: 10 passed.
