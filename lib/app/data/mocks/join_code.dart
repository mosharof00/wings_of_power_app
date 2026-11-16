import '../../core/network/api_exception.dart';
import '../models/auth_models/join_code_model.dart';

/// Fixture for `POST /api/auth/student/join-code` when [AppConfig.useMocks].
///
/// Matches backend seed / admin format: 6-digit numeric codes.
class JoinCodeMock {
  JoinCodeMock._();

  static const successCode = '864320';
  static const expiredCode = '000000';

  static JoinCodePreview resolve(String code) {
    final normalized = code.trim();
    if (normalized == successCode) {
      return const JoinCodePreview(
        className: 'Grade 4 · Amber',
        teacherName: 'Demo Teacher',
        classId: 'grade-4-amber',
      );
    }
    if (normalized == expiredCode) {
      throw ApiException('EXPIRED', statusCode: 422);
    }
    throw ApiException('WRONG_CODE', statusCode: 404);
  }
}
