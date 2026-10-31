import '../../core/network/api_exception.dart';
import '../models/auth_models/join_code_model.dart';

/// Fixture for `POST /api/auth/student/join-code` until T-BE-010.
///
/// `123456` succeeds, `000000` is expired, any other code is wrong.
class JoinCodeMock {
  JoinCodeMock._();

  static const successCode = '123456';
  static const expiredCode = '000000';

  static JoinCodePreview resolve(String code) {
    if (code == successCode) {
      return const JoinCodePreview(
        className: 'Grade 5',
        teacherName: 'Ms. Smith',
        classId: 'grade-5-ms-smith',
      );
    }
    if (code == expiredCode) {
      throw ApiException('EXPIRED', statusCode: 422);
    }
    throw ApiException('WRONG_CODE', statusCode: 404);
  }
}
