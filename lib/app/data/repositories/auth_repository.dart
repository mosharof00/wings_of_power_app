import 'package:wings_of_power_app/app/core/config/app_config.dart';
import 'package:wings_of_power_app/app/core/network/api_client.dart';
import 'package:wings_of_power_app/app/core/network/api_endpoints.dart';
import 'package:wings_of_power_app/app/data/mocks/join_code.dart';
import 'package:wings_of_power_app/app/data/mocks/login.dart';
import 'package:wings_of_power_app/app/data/mocks/register.dart';
import 'package:wings_of_power_app/app/data/models/auth_models/join_code_model.dart';
import 'package:wings_of_power_app/app/data/models/auth_models/register_model.dart';
import 'package:wings_of_power_app/app/data/models/auth_models/student_session.dart';
import 'package:wings_of_power_app/app/data/models/user_models/user_model.dart';

abstract class IAuthRepository {
  Future<StudentSession> loginStudent({
    required String username,
    required String password,
    required bool remember,
  });

  Future<JoinCodePreview> joinCode({required String code});

  Future<RegisterResult> registerStudent({
    required String code,
    required String username,
    required String password,
    required String nickname,
    required String realName,
  });

  Future<UserModel> getMe();

  Future<void> logout();
}

class AuthRepository implements IAuthRepository {
  final ApiClient _client;

  AuthRepository(this._client);

  @override
  Future<StudentSession> loginStudent({
    required String username,
    required String password,
    required bool remember,
  }) async {
    if (AppConfig.useMocks) {
      return LoginMock.submit(
        username: username,
        password: password,
        remember: remember,
      );
    }
    return _client.handleRequest(
      () => _client.dio.post(
        ApiEndpoint.studentLogin,
        data: {
          'username': username,
          'password': password,
          'remember': remember,
        },
      ),
      (dynamic data) =>
          StudentSession.fromJson(Map<String, dynamic>.from(data as Map)),
      'Login',
    );
  }

  @override
  Future<JoinCodePreview> joinCode({required String code}) async {
    if (AppConfig.useMocks) return JoinCodeMock.resolve(code);
    return _client.handleRequest(
      () => _client.dio.post(ApiEndpoint.studentJoinCode, data: {'code': code}),
      (dynamic data) =>
          JoinCodePreview.fromJson(Map<String, dynamic>.from(data as Map)),
      'Join code',
    );
  }

  @override
  Future<RegisterResult> registerStudent({
    required String code,
    required String username,
    required String password,
    required String nickname,
    required String realName,
  }) async {
    if (AppConfig.useMocks) {
      return RegisterMock.submit(
        code: code,
        username: username,
        password: password,
        nickname: nickname,
        realName: realName,
      );
    }
    return _client.handleRequest(
      () => _client.dio.post(
        ApiEndpoint.studentRegister,
        data: {
          'code': code,
          'username': username,
          'password': password,
          'nickname': nickname,
          'realName': realName,
        },
      ),
      (dynamic data) =>
          RegisterResult.fromJson(Map<String, dynamic>.from(data as Map)),
      'Register',
    );
  }

  @override
  Future<UserModel> getMe() async {
    if (AppConfig.useMocks) {
      return LoginMock.current ?? RegisterMock.pendingMe();
    }
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.me),
      (dynamic data) => UserModel.fromJson(data),
      'Get Me',
    );
  }

  @override
  Future<void> logout() {
    return _client.handleRequest(
      () => _client.dio.post(ApiEndpoint.logout),
      (_) {},
      'Logout',
    );
  }
}
