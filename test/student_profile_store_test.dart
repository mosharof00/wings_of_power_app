import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:wings_of_power_app/app/core/network/api_client.dart';
import 'package:wings_of_power_app/app/data/models/home_models.dart';
import 'package:wings_of_power_app/app/data/models/user_models/student_profile_model.dart';
import 'package:wings_of_power_app/app/data/repositories/achievement_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/home_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/igame_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/profile_repository.dart';
import 'package:wings_of_power_app/app/data/services/student_profile_store.dart';
import 'package:wings_of_power_app/app/modules/achievements/controllers/achievements_controller.dart';
import 'package:wings_of_power_app/app/modules/game/controllers/game_mode_select_controller.dart';
import 'package:wings_of_power_app/app/modules/home/controllers/home_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  test(
    'reads the wrapped profile and updates the shared Home and game identity',
    () async {
      final client = ApiClient();
      var saved = const StudentProfileModel(
        id: 'student-1',
        nickname: 'Avery',
        avatarUrl: 'assets/images/avatar_02.png',
        ageText: '9 years old',
        points: 75,
        badges: 2,
        progressPercent: 38,
        studentClass: StudentClassInfo(id: 'class-1', name: 'Room 10'),
      );
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.method == 'PATCH') {
              final body = options.data as Map;
              saved = saved.copyWith(
                nickname: body['nickname'] as String?,
                avatarUrl: body['avatarUrl'] as String?,
              );
            }
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'success': true,
                  'data': Map<String, dynamic>.of(saved.toJson())
                    ..remove('ageText')
                    ..['age'] = 9,
                },
              ),
            );
          },
        ),
      );

      final store = Get.put(StudentProfileStore(ProfileRepository(client)));
      addTearDown(() => Get.reset());
      final home = HomeController(_HomeRepository());
      addTearDown(home.onClose);
      final game = GameModeSelectController(_GameRepository());

      await store.refresh();
      expect(home.greeting, 'Hey Avery!');
      expect(game.nickname, 'Avery');
      expect(game.avatarUrl, home.avatarUrl);
      expect(store.profile.value?.ageText, '9 years old');
      expect(store.profile.value?.displayClassName, 'Room 10');

      await store.update(
        nickname: 'Casey',
        avatarUrl: 'assets/images/avatar_07.png',
      );
      expect(home.greeting, 'Hey Casey!');
      expect(game.nickname, 'Casey');
      expect(home.avatarUrl, 'assets/images/avatar_07.png');
      expect(game.avatarUrl, home.avatarUrl);
      expect(game.coins, 75);
      expect(store.profile.value?.progressPercent, 38);

      await store.update(avatarUrl: 'assets/images/avatar_08.png');
      expect(home.avatarUrl, 'assets/images/avatar_08.png');
      expect(home.greeting, 'Hey Casey!');
    },
  );

  test('Badges loads the API list and reads saved student points', () async {
    final client = ApiClient();
    client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final Object data = options.path.endsWith('/badges')
              ? [
                  {
                    'id': 'kindness',
                    'code': 'KINDNESS_CHAMPION',
                    'name': 'Kindness Champion',
                    'earned': true,
                    'earnedAt': '2026-11-22T00:00:00.000Z',
                  },
                  {
                    'id': 'explorer',
                    'code': 'STORY_EXPLORER',
                    'name': 'Story Explorer',
                    'earned': false,
                  },
                ]
              : {'id': 'student-1', 'nickname': 'Avery', 'points': 75};
          handler.resolve(
            Response(
              requestOptions: options,
              data: {'success': true, 'data': data},
            ),
          );
        },
      ),
    );
    Get.put(StudentProfileStore(ProfileRepository(client)));
    addTearDown(() => Get.reset());
    final achievements = AchievementsController(AchievementRepository(client));

    await achievements.fetchBadges();

    expect(achievements.totalCount.value, 2);
    expect(achievements.earnedCount.value, 1);
    expect(achievements.studentPoints, 75);
    expect(
      achievements.badges.first.assetPath,
      'assets/badges/badge_kindness_champion.png',
    );
    expect(achievements.badges.first.unlockedAt, isNotNull);
    expect(achievements.badges.last.isEarned, isFalse);
  });

  test(
    'an in-flight profile response cannot restore a previous session',
    () async {
      final repository = _DelayedProfileRepository();
      final store = StudentProfileStore(repository);
      final request = store.refresh();
      store.reset();
      repository.request.complete(
        const StudentProfileModel(
          id: 'old-student',
          nickname: 'Old Student',
          avatarUrl: 'assets/images/avatar_04.png',
          points: 10,
          badges: 1,
        ),
      );
      await request;
      expect(store.profile.value, isNull);
    },
  );
}

class _HomeRepository implements IHomeRepository {
  @override
  Future<HomeDataModel> getHome() async => const HomeDataModel(
    greeting: 'Welcome!',
    subtitle: '',
    points: 0,
    categories: [],
    popularStories: [],
  );
}

class _GameRepository implements IGameRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DelayedProfileRepository implements IProfileRepository {
  final request = Completer<StudentProfileModel>();

  @override
  Future<StudentProfileModel> getProfile() => request.future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
