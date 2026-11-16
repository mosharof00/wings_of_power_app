import '../models/auth_models/register_model.dart';
import '../models/user_models/user_model.dart';

/// Fixture for student register and `GET /api/auth/me` until T-BE-010.
///
/// Register always returns status `PENDING` and a setup token. [code],
/// [password], and [nickname] are part of the request the real call sends.
class RegisterMock {
  RegisterMock._();

  static const accessToken = 'mock-setup-token';
  static const takenUsernames = {'wingkid', 'taken'};

  static UserModel? current;

  static bool isUsernameAvailable(String username) {
    final value = username.trim().toLowerCase();
    return value.isNotEmpty && !takenUsernames.contains(value);
  }

  static RegisterResult submit({
    required String code,
    required String username,
    required String password,
    required String confirmPassword,
    required String nickname,
    required String realName,
    required int age,
    String? avatarUrl,
  }) {
    if (password != confirmPassword) {
      throw StateError('Passwords do not match');
    }
    if (!isUsernameAvailable(username)) {
      throw StateError('Username already registered');
    }
    final user = UserModel(
      success: true,
      data: UserData(
        id: 'student-pending',
        name: realName,
        username: username,
        about: nickname,
        avatar: avatarUrl,
        type: 'STUDENT',
        status: 'PENDING',
        dateOfBirth: DateTime(DateTime.now().year - age),
      ),
    );
    current = user;
    return RegisterResult(user: user, accessToken: accessToken);
  }

  static UserModel pendingMe() {
    return current ??
        UserModel(
          success: true,
          data: UserData(
            id: 'student-pending',
            type: 'STUDENT',
            status: 'PENDING',
          ),
        );
  }
}
