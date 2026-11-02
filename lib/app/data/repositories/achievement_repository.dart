import 'package:wings_of_power_app/app/core/config/app_config.dart';
import 'package:wings_of_power_app/app/core/network/api_client.dart';
import 'package:wings_of_power_app/app/core/network/api_endpoints.dart';
import '../mocks/achievements.dart';
import '../models/achievement_models.dart';

abstract class IAchievementRepository {
  Future<BadgesResponseModel> getBadges({String? fixtureState});
  Future<BadgeModel> getBadgeDetail(String id);
  Future<PositivePointsModel> getStudentPoints({int page = 1, int perPage = 20});
  Future<LeaderboardModel> getStudentLeaderboard({String scope = 'class'});
  Future<ReadingProgressModel> getStudentReadingProgress();
}

class AchievementRepository implements IAchievementRepository {
  final ApiClient _client;

  AchievementRepository(this._client);

  @override
  Future<BadgesResponseModel> getBadges({String? fixtureState}) async {
    if (AppConfig.useMocks) {
      if (fixtureState == 'all_locked') {
        return AchievementsMock.allLockedBadges;
      }
      if (fixtureState == 'partial') {
        return AchievementsMock.partialBadges;
      }
      if (fixtureState == 'profile_tab') {
        return AchievementsMock.profileBadgesTab;
      }
      return AchievementsMock.allEarnedBadges;
    }

    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.badges),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map<String, dynamic>
            : (data is Map ? data as Map<String, dynamic> : <String, dynamic>{});
        return BadgesResponseModel.fromJson(map);
      },
      'Get Badges',
    );
  }

  @override
  Future<BadgeModel> getBadgeDetail(String id) async {
    if (AppConfig.useMocks) {
      return AchievementsMock.getBadgeById(id);
    }

    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.badgeDetail(id)),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map<String, dynamic>
            : (data is Map ? data as Map<String, dynamic> : <String, dynamic>{});
        return BadgeModel.fromJson(map);
      },
      'Get Badge Detail',
    );
  }

  @override
  Future<PositivePointsModel> getStudentPoints({
    int page = 1,
    int perPage = 20,
  }) async {
    if (AppConfig.useMocks) {
      return AchievementsMock.positivePoints;
    }

    return _client.handleRequest(
      () => _client.dio.get(
        ApiEndpoint.studentPoints,
        queryParameters: {'page': page, 'perPage': perPage},
      ),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map<String, dynamic>
            : (data is Map ? data as Map<String, dynamic> : <String, dynamic>{});
        return PositivePointsModel.fromJson(map);
      },
      'Get Student Points',
    );
  }

  @override
  Future<LeaderboardModel> getStudentLeaderboard({String scope = 'class'}) async {
    if (AppConfig.useMocks) {
      return AchievementsMock.leaderboard;
    }

    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.studentLeaderboard(scope)),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map<String, dynamic>
            : (data is Map ? data as Map<String, dynamic> : <String, dynamic>{});
        return LeaderboardModel.fromJson(map);
      },
      'Get Student Leaderboard',
    );
  }

  @override
  Future<ReadingProgressModel> getStudentReadingProgress() async {
    if (AppConfig.useMocks) {
      return AchievementsMock.readingProgress;
    }

    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.studentReadingProgress),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map<String, dynamic>
            : (data is Map ? data as Map<String, dynamic> : <String, dynamic>{});
        return ReadingProgressModel.fromJson(map);
      },
      'Get Student Reading Progress',
    );
  }
}
