import '../models/game_eligibility.dart';
import '../models/how_to_play.dart';

abstract class IGameRepository {
  Future<GameEligibilityModel> getEligibility();
  Future<HowToPlayModel> getHowToPlay();
}

