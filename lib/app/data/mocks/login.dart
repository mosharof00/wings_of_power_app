import '../../core/network/api_exception.dart';
import '../models/auth_models/student_session.dart';
import '../models/user_models/user_model.dart';

/// Fixture for `POST /api/auth/student/login` until T-BE-010.
///
/// `sam` / `secret1` returns a token. `pending` is 422 PENDING.
/// Any other pair is 401.
class LoginMock {
  LoginMock._();

  static const activeUsername = 'sam';
  static const activePassword = 'secret1';
  static const pendingUsername = 'pending';
  static const accessToken = 'mock-login-token';

  /// Last successful login. [AuthRepository.getMe] reads this while mocks are on.
  static UserModel? current;

  static StudentSession submit({
    required String username,
    required String password,
    required bool remember,
  }) {
    if (username == pendingUsername) {
      throw ApiException('PENDING', statusCode: 422);
    }
    if (username == activeUsername && password == activePassword) {
      current = UserModel(
        success: true,
        data: UserData(
          id: 'student-active',
          username: username,
          type: 'STUDENT',
          status: 'ACTIVE',
        ),
      );
      return StudentSession(
        userId: 'student-active',
        accessToken: accessToken,
        status: 'ACTIVE',
      );
    }
    throw ApiException('UNAUTHORIZED', statusCode: 401);
  }
}
