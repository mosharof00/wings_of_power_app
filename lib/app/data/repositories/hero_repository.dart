import 'package:wings_of_power_app/app/core/config/app_config.dart';
import 'package:wings_of_power_app/app/core/network/api_client.dart';
import 'package:wings_of_power_app/app/core/network/api_endpoints.dart';
import '../mocks/heroes.dart';
import '../models/hero_models.dart';

abstract class IHeroRepository {
  Future<List<HeroModel>> getHeroes();
  Future<HeroModel> selectHero(String id);
}

class HeroRepository implements IHeroRepository {
  final ApiClient _client;

  HeroRepository(this._client);

  @override
  Future<List<HeroModel>> getHeroes() async {
    if (AppConfig.useMocks) {
      return HeroesMock.getHeroes();
    }
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.heroes),
      (dynamic data) {
        final list = (data is Map && data['data'] is List)
            ? data['data'] as List
            : (data is List ? data : []);
        return list
            .map((item) =>
                HeroModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      },
      'Get Heroes',
    );
  }

  @override
  Future<HeroModel> selectHero(String id) async {
    if (AppConfig.useMocks) {
      return HeroesMock.select(id);
    }
    return _client.handleRequest(
      () => _client.dio.post(ApiEndpoint.heroSelect(id)),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map
            : (data is Map ? data : {'id': id});
        return HeroModel.fromJson(Map<String, dynamic>.from(map));
      },
      'Select Hero',
    );
  }
}
