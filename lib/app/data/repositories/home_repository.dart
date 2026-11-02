import 'package:wings_of_power_app/app/core/config/app_config.dart';
import 'package:wings_of_power_app/app/core/network/api_client.dart';
import 'package:wings_of_power_app/app/core/network/api_endpoints.dart';
import '../mocks/home.dart';
import '../models/home_models.dart';

abstract class IHomeRepository {
  Future<HomeDataModel> getHome();
}

class HomeRepository implements IHomeRepository {
  final ApiClient _client;

  HomeRepository(this._client);

  @override
  Future<HomeDataModel> getHome() async {
    if (AppConfig.useMocks) {
      return HomeMock.getHome();
    }
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.studentHome),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map
            : (data is Map ? data : {});
        return HomeDataModel.fromJson(Map<String, dynamic>.from(map));
      },
      'Get Student Home',
    );
  }
}
