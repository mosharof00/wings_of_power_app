import 'package:wings_of_power_app/app/core/network/api_client.dart';
import 'package:wings_of_power_app/app/core/network/api_endpoints.dart';
import 'package:wings_of_power_app/app/data/models/auth_models/login_model.dart';
import 'package:wings_of_power_app/app/data/models/user_models/user_model.dart';

abstract class IAuthRepository {
  Future<LoginModel> login({required String email, required String password});

  Future<UserModel> getMe();

  Future<void> logout();
}

class AuthRepository implements IAuthRepository {
  final ApiClient _client;

  AuthRepository(this._client);

  @override
  Future<LoginModel> login({required String email, required String password}) {
    return _client.handleRequest(
      () => _client.dio.post(
        ApiEndpoint.login,
        data: {'email': email, 'password': password},
      ),
      (dynamic data) => LoginModel.fromJson(data),
      'Login',
    );
  }

  @override
  Future<UserModel> getMe() {
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
