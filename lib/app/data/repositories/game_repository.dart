import 'package:wings_of_power_app/app/core/config/app_config.dart';
import 'package:wings_of_power_app/app/core/network/api_client.dart';
import 'package:wings_of_power_app/app/core/network/api_endpoints.dart';
import '../models/game_eligibility.dart';
import '../models/how_to_play.dart';
import 'igame_repository.dart';

class GameRepository implements IGameRepository {
  final ApiClient _client;

  GameRepository(this._client);

  @override
  Future<GameEligibilityModel> getEligibility() async {
    if (AppConfig.useMocks) {
      return getMockEligibility();
    }
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.gameEligibility),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map
            : (data is Map ? data : {});
        return GameEligibilityModel.fromJson(Map<String, dynamic>.from(map));
      },
      'Get Game Eligibility',
    );
  }

  @override
  Future<HowToPlayModel> getHowToPlay() async {
    if (AppConfig.useMocks) {
      return getMockHowToPlay();
    }
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.gameHowToPlay),
      (dynamic data) {
        final res = (data is Map && data.containsKey('data'))
            ? data['data']
            : data;
        return HowToPlayModel.fromJson(res);
      },
      'Get Game How To Play',
    );
  }

  static GameEligibilityModel getMockEligibility({bool eligible = true}) {
    return GameEligibilityModel(
      eligible: eligible,
      progress: GameEligibilityProgress(
        storiesCompleted: eligible ? 2 : 0,
        chaptersCompleted: eligible ? 6 : 0,
        bestQuizPercent: eligible ? 85.0 : 0.0,
      ),
      rules: GameEligibilityRules(
        requiredStories: 2,
        requiredChapters: 6,
        minQuizPercent: 70,
      ),
    );
  }

  static HowToPlayModel getMockHowToPlay() {
    return HowToPlayModel(steps: HowToPlayModel.defaultSteps);
  }
}

