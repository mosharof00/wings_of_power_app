import '../models/game_eligibility.dart';
import '../models/game_match.dart';
import '../models/hero_models.dart';
import '../models/how_to_play.dart';
import '../models/user_models/student_profile_model.dart';

abstract class IGameRepository {
  Future<GameEligibilityModel> getEligibility();
  Future<HowToPlayModel> getHowToPlay();

  Future<List<HeroModel>> getHeroes();
  Future<HeroModel> selectHero(String id);

  Future<StudentProfileModel> updateAvatar(String avatarUrl);

  Future<GameQueueResponse> joinQueue({
    required String mode,
    String? fixtureCode,
  });

  Future<void> cancelQueue();

  Future<GameMatchSnapshot> getMatchSnapshot(String matchId);

  Future<void> leaveMatch(String matchId);
}
