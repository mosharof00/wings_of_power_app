import 'package:wings_of_power_app/app/core/config/app_config.dart';
import 'package:wings_of_power_app/app/core/network/api_client.dart';
import 'package:wings_of_power_app/app/core/network/api_endpoints.dart';
import '../mocks/heroes.dart';
import '../mocks/profile.dart';
import '../models/game_eligibility.dart';
import '../models/game_match.dart';
import '../models/hero_models.dart';
import '../models/how_to_play.dart';
import '../models/leaderboard_entry.dart';
import '../models/user_models/student_profile_model.dart';
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

  @override
  Future<StudentProfileModel> updateAvatar(String avatarUrl) async {
    if (AppConfig.useMocks) {
      return ProfileMock.updateProfile(avatarUrl: avatarUrl);
    }
    return _client.handleRequest(
      () => _client.dio.patch(
        ApiEndpoint.studentProfile,
        data: {'avatarUrl': avatarUrl},
      ),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map
            : (data is Map ? data : {});
        return StudentProfileModel.fromJson(Map<String, dynamic>.from(map));
      },
      'Update Avatar',
    );
  }

  @override
  Future<GameQueueResponse> joinQueue({
    required String mode,
    String? fixtureCode,
  }) async {
    if (AppConfig.useMocks) {
      return GameQueueResponse(
        matchId: 'mock-practice-match-${DateTime.now().millisecondsSinceEpoch}',
        ticketId: 'mock-ticket-practice',
        mode: mode,
      );
    }
    final queueUrl = '${ApiEndpoint.baseUrl}/game/queue';
    final payload = <String, dynamic>{
      'mode': mode,
      if (fixtureCode != null && fixtureCode.trim().isNotEmpty)
        'fixtureCode': fixtureCode.trim(),
    };
    return _client.handleRequest(
      () => _client.dio.post(queueUrl, data: payload),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map
            : (data is Map ? data : {});
        return GameQueueResponse.fromJson(Map<String, dynamic>.from(map));
      },
      'Join Game Queue',
    );
  }

  @override
  Future<void> cancelQueue() async {
    if (AppConfig.useMocks) {
      return;
    }
    final queueUrl = '${ApiEndpoint.baseUrl}/game/queue';
    return _client.handleRequest(
      () => _client.dio.delete(queueUrl),
      (_) {},
      'Cancel Game Queue',
    );
  }

  @override
  Future<GameMatchSnapshot> getMatchSnapshot(String matchId) async {
    if (AppConfig.useMocks) {
      return getMockMatchSnapshot(matchId: matchId);
    }
    final matchUrl = '${ApiEndpoint.baseUrl}/game/matches/$matchId';
    return _client.handleRequest(
      () => _client.dio.get(matchUrl),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map
            : (data is Map ? data : {});
        return GameMatchSnapshot.fromJson(Map<String, dynamic>.from(map));
      },
      'Get Match Snapshot',
    );
  }

  @override
  Future<void> leaveMatch(String matchId) async {
    if (AppConfig.useMocks) {
      return;
    }
    final leaveUrl = '${ApiEndpoint.baseUrl}/game/matches/$matchId/leave';
    return _client.handleRequest(
      () => _client.dio.post(leaveUrl),
      (_) {},
      'Leave Match',
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

  static GameMatchSnapshot getMockMatchSnapshot({
    String matchId = 'mock-practice-1',
    String? fixtureCode,
    String? nickname,
  }) {
    return GameMatchSnapshot(
      matchId: matchId,
      mode: 'SINGLE',
      phase: 'COUNTDOWN',
      deadlineAt: DateTime.now().add(const Duration(seconds: 3)),
      serverNow: DateTime.now(),
      teams: [
        GameMatchTeam(
          id: 'team-mock-1',
          label: 'Single Player',
          scoreXp: 0,
          scoreKindness: 0,
          scoreBaskets: 0,
          members: [
            GameMatchParticipant(
              id: 'part-mock-you',
              userId: 'student-sarah',
              nickname: nickname ?? 'Sarah',
              avatarUrl: 'assets/images/avatar_01.png',
              heroId: 'hero-faith',
              jerseyNumber: 1,
              isConnected: true,
              isBot: false,
            ),
            const GameMatchParticipant(
              id: 'part-mock-bot',
              userId: null,
              nickname: 'Practice Bot',
              avatarUrl: null,
              heroId: 'hero-harold',
              jerseyNumber: 2,
              isConnected: true,
              isBot: true,
            ),
          ],
        ),
      ],
      you: const GameMatchYou(
        participantId: 'part-mock-you',
        canBuzz: false,
        powerUsed: false,
        heroId: 'hero-faith',
        jerseyNumber: 1,
      ),
    );
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard({String scope = 'school'}) async {
    if (AppConfig.useMocks) {
      return [
        const LeaderboardEntry(
          id: '1',
          rank: 1,
          nickname: 'Alex',
          kindnessPoints: 295,
          avatarUrl: 'assets/images/avatar_01.png',
          isCurrentStudent: true,
        ),
        const LeaderboardEntry(
          id: '2',
          rank: 2,
          nickname: 'Casey',
          kindnessPoints: 245,
          avatarUrl: 'assets/images/avatar_02.png',
        ),
        const LeaderboardEntry(
          id: '3',
          rank: 3,
          nickname: 'Taylor',
          kindnessPoints: 190,
          avatarUrl: 'assets/images/avatar_03.png',
        ),
      ];
    }
    return _client.handleRequest(
      () => _client.dio.get(
        ApiEndpoint.studentLeaderboard(scope),
      ),
      (dynamic data) {
        final list = (data is Map && data['data'] is List)
            ? data['data'] as List
            : (data is List ? data : []);
        return list
            .map((item) =>
                LeaderboardEntry.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      },
      'Get Game Leaderboard',
    );
  }
}
