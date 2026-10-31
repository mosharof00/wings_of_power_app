# T-APP-007 — Credentials, nickname, real name, account verification

**Status:** done

**Depends on:** T-APP-006

## Scope

`student.setup_credentials`, `student.nickname`, `student.real_name`, `student.pending_approval`.

`Profile.png` in the auth folder is account setup (username, password, confirm password), not the profile hub (`T-APP-017`).

Collect fields across the three forms, then one register call. JSON fields are the Auth module table in `docs/API.md`: `code`, `username`, `password`, `nickname`, `realName`. The flow sketch in that file writes `real_name`; the app sends `realName`.

Show the step label that is printed on each PNG (`1/2` on credentials, `1/2` on nickname, `2/2` on real name). Do not renumber them. The clash is already in `docs/OPEN_QUESTIONS.md`.

Account verification is the dead end “Approval Needed!”. No button. The student cannot open the tab shell while `GET /api/auth/me` is `PENDING`. Login (`T-APP-008`) and hero select (`T-APP-009`) route here when status is `PENDING`.

Mock until `T-BE-010`. Register returns a user with status `PENDING` and a setup token when the API returns one. `GET /api/auth/me` returns that status.

Password rules: confirm must match. Username required. The screens do not show a strength meter; do not add one.

## Screenshots

- `design/screens/student/authentication_&_character_choose/Profile.png`
- `design/screens/student/authentication_&_character_choose/Nick Name.png`
- `design/screens/student/authentication_&_character_choose/Real Name.png` — empty
- `design/screens/student/authentication_&_character_choose/Real Name-1.png` — Sarah, Continue enabled
- `design/screens/student/authentication_&_character_choose/Account verification.png`

## Assets

Auth sky from `T-APP-006`. No extra illustrations on these forms.

## API

Mock until `T-BE-010`:

- `POST /api/auth/student/register` — `code`, `username`, `password`, `nickname`, `realName`
- `GET /api/auth/me` — status `PENDING` shows this dead end

`PATCH /api/student/profile` is for later nickname edits (`T-APP-017`), not this first-run form.

## States

- Credentials empty and ready to continue (step label as on `Profile.png`)
- Nickname with value (PNG shows Mini)
- Real name empty
- Real name filled (Sarah)
- Password mismatch stays on credentials
- Approval Needed, no actions

## Navigation

- In: join success “Set Up your Profile”; also `T-APP-008` and `T-APP-009` when me/login says `PENDING`
- Continue on credentials → nickname
- Next on nickname → real name
- Continue on real name → `POST` register → character choose (`T-APP-009`)
- Account verification: no outgoing navigation

## Allowed files

- `lib/app/modules/account_setup/**` (new: credentials, nickname, real name, pending)
- `lib/app/data/repositories/auth_repository.dart`
- `lib/app/data/models/auth_models/**`
- `lib/app/data/models/user_models/**` (status field if missing)
- `lib/app/data/mocks/register.dart`
- `lib/app/core/network/api_endpoints.dart`
- `lib/app/routes/app_pages.dart`
- `lib/app/routes/app_routes.dart`
- This file (Status / Notes)

## Done when

- `flutter analyze` is clean
- `flutter test` passes
- Runs on a simulator
- The five screenshots match at 375×812, including both real-name states and the printed step labels
- One register call carries all fields
- Pending screen has no path into home

## Notes

- Step labels stay as printed: `1/2` on credentials, `1/2` on nickname, `2/2` on real name. Not renumbered (OPEN_QUESTIONS item 7).
- Register JSON uses `realName`. Mock token is `mock-setup-token`. User status is always `PENDING`. Nickname is kept on `UserData.about` so the mock does not drop it. `GET /api/auth/me` while `useMocks` returns that user.
- `code` and `classId` come from the join-success arguments. Register sends `code`, `username`, `password`, `nickname`, `realName`. `classId` is forwarded to the character-choose route for T-APP-009.
- Empty username, empty password, or a password mismatch stays on credentials. No extra error copy (not on the PNG). Credentials Continue stays enabled on an empty form, matching Profile.png. Nickname Next and real-name Continue stay disabled until the field has text.
- Real name starts empty with the keyboard up. Filled “Sarah” and nickname “Mini” are screenshot states, not defaults.
- Account verification is `/pending-approval` (`PopScope` cannot pop, no button). This task’s register path does not open it; Continue on real name goes to a blank `/character-choose` scaffold until T-APP-009. Login and hero select can open the pending route later.
- `assets/characters/hero_approval.png` is the approval character (sky and the navy title knocked out, shoes kept). The three forms have no character art. Forms and the pending screen use `bg_auth_sky`.
- Splash is outside this task’s allowed files. A persisted setup token still sends a cold start to the home shell. The pending screen itself has no path into home.
- Checked on iPhone 18 Pro Max: credentials, nickname (Mini), empty real name (peach Continue, keyboard), Sarah with Continue enabled, and Approval Needed. `flutter analyze` clean. `flutter test` 10 passed. Capture timers removed. Initial route restored to splash.
