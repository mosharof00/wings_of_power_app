# T-APP-008 — Login

**Status:** done

**Depends on:** T-APP-004

Welcome’s “Log In” (`T-APP-006`) and the code screen’s “Already Joined? Login Here” open this route. The route can exist as a shell before this task paints it.

## Scope

`student.login` — `Login-1.png`.

Fields: User Name, Password, Remember Device. Actions: show/hide password, Forgot Password?, Let’s Get Started, Join with code.

Remember Device uses the existing persist flag in `HelperUtils.setUser` (`SecureStorage` vs session).

Forgot Password? is drawn because it is on the PNG. There is no student reset screenshot. The control does not open a new screen. `POST /api/auth/student/forgot-password` is P1 and stays unwired until a screen exists.

Join with code → `T-APP-006` code screen.

Mock until `T-BE-010`.

| Response | Result |
|----------|--------|
| token | `Get.offAllNamed` home shell |
| 401 | message on this form |
| 422 `PENDING` | account verification (`T-APP-007`) |

Student login body is `username`, `password`, `remember` — not the demo email field. Endpoint `POST /api/auth/student/login`.

## Screenshots

- `design/screens/student/authentication_&_character_choose/Login-1.png`

`Login.png` and `With code.png` are the welcome screen in `T-APP-006`, not this form.

## Assets

Auth background from `T-APP-006`. Character art on the form only if `Login-1.png` shows it.

## API

Mock until `T-BE-010`:

- `POST /api/auth/student/login` `{ username, password, remember? }`
- Errors 401, 422 `PENDING`

## States

- Empty form
- Filled form (Let’s Get Started enabled)
- Password visible / hidden
- Remember Device on / off
- 401 error
- Loading on the button

## Navigation

- In: welcome Log In; code screen “Already Joined? Login Here”
- Success → home (`T-APP-010`)
- 422 PENDING → account verification (`T-APP-007`)
- Join with code → class code (`T-APP-006`)
- Forgot Password? stays on this screen

## Allowed files

- `lib/app/modules/login/**`
- `lib/app/data/repositories/auth_repository.dart`
- `lib/app/data/models/auth_models/**`
- `lib/app/data/mocks/login.dart`
- `lib/app/core/network/api_endpoints.dart`
- `lib/app/core/utils/helper_utils.dart` (remember / token only)
- `lib/app/routes/app_pages.dart`
- `lib/app/routes/app_routes.dart`
- This file (Status / Notes)

## Done when

- `flutter analyze` is clean
- `flutter test` passes
- Runs on a simulator
- `Login-1.png` matches at 375×812
- Success, 401, and pending each follow the table above
- No forgot-password screen

## Notes

- Login screen matches auth_login_filled.png (Login-1.png) at 375×812.
- Fields: username, password (toggle obscure), remember device checkbox, forgot password link (no screen opened, remains on page), let's get started button (disabled when empty, enabled when both fields filled), join with code navigation.
- AuthRepository / LoginMock wired: sam/secret1 -> ACTIVE session + home shell (Routes.MAIN_PAGE); pending -> 422 PENDING to Routes.PENDING_APPROVAL; wrong credentials -> 401 error message displayed on form.
- Session persistence via HelperUtils.setUser(persist: remember.value).
- Initial app route restored to Routes.SPLASH in AppPages.
- Validation: flutter analyze clean, flutter test passed (10 tests), iOS simulator build succeeded.
