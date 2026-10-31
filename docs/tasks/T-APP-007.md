# T-APP-007 — Credentials, nickname, real name, account verification

**Status:** todo

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

-
