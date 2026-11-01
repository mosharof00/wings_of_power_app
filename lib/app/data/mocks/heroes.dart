import '../models/hero_models.dart';

/// Fixture for hero roster and selection until T-BE-014.
class HeroesMock {
  HeroesMock._();

  static bool allUnlockedOverride = false;
  static String? selectedIdOverride;

  static final List<HeroModel> _defaultHeroes = [
    const HeroModel(
      id: 'hero-faith',
      code: 'FAITH',
      displayName: 'Faith',
      roleTitle: 'Violinist',
      bulliedFor: 'loving to play the violin',
      powerCode: 'MELODY',
      powerLabel: 'Melody Shot',
      powerDescription: 'extra focus time',
      quote: '"My music makes me strong."',
      assetPath: 'assets/characters/hero_faith.png',
      sortOrder: 1,
      unlockStoriesRequired: 0,
      isUnlocked: true,
      isSelected: false,
    ),
    const HeroModel(
      id: 'hero-michele',
      code: 'MICHELE',
      displayName: 'Michele',
      roleTitle: 'Artist',
      bulliedFor: 'her art and her beautiful unique skin pigmentation',
      powerCode: 'COLOR',
      powerLabel: 'Color Shot',
      powerDescription: 'freezes timer',
      quote: '"My art and my skin tell my story."',
      assetPath: 'assets/characters/hero_michele.png',
      sortOrder: 2,
      unlockStoriesRequired: 0,
      isUnlocked: true,
      isSelected: true,
    ),
    const HeroModel(
      id: 'hero-michael',
      code: 'MICHAEL',
      displayName: 'Michael',
      roleTitle: 'Chess Thinker',
      bulliedFor: 'loving chess',
      powerCode: 'CHECKMATE',
      powerLabel: 'Checkmate Shot',
      powerDescription: 'sees defense strategy',
      quote: '"Smart moves win kind games."',
      assetPath: 'assets/characters/hero_michael.png',
      sortOrder: 3,
      unlockStoriesRequired: 0,
      isUnlocked: true,
      isSelected: false,
    ),
    const HeroModel(
      id: 'hero-samantha',
      code: 'SAMANTHA',
      displayName: 'Samantha',
      roleTitle: 'Singer',
      bulliedFor: 'playing guitar and singing',
      powerCode: 'HARMONY',
      powerLabel: 'Harmony Shot',
      powerDescription: 'ask teammate for help',
      quote: '"My voice deserves to be heard."',
      assetPath: 'assets/characters/hero_samantha.png',
      sortOrder: 4,
      unlockStoriesRequired: 2,
      isUnlocked: false,
      isSelected: false,
    ),
    const HeroModel(
      id: 'hero-chi-sung',
      code: 'CHI_SUNG',
      displayName: 'Chi Sung',
      roleTitle: 'Numbers Star',
      bulliedFor: 'loving statistics and geometry',
      powerCode: 'PRISM',
      powerLabel: 'Prism Shot',
      powerDescription:
          'calculates the perfect angle, shows probability of each answer',
      quote: '"Numbers tell beautiful stories."',
      assetPath: 'assets/characters/hero_chi_sung.png',
      sortOrder: 5,
      unlockStoriesRequired: 2,
      isUnlocked: false,
      isSelected: false,
    ),
    const HeroModel(
      id: 'hero-ralph',
      code: 'RALPH',
      displayName: 'Ralph',
      roleTitle: 'Nature Explorer',
      bulliedFor: 'carrying magnifying glass, loving insects',
      powerCode: 'NATURE',
      powerLabel: 'Nature Shot',
      powerDescription: 'reveals animal hint',
      quote: '"Small things matter."',
      assetPath: 'assets/characters/hero_ralph.png',
      sortOrder: 6,
      unlockStoriesRequired: 2,
      isUnlocked: false,
      isSelected: false,
    ),
    const HeroModel(
      id: 'hero-harold',
      code: 'HAROLD',
      displayName: 'Harold',
      roleTitle: 'Young Scientist',
      bulliedFor: 'loving science too much',
      powerCode: 'LAB',
      powerLabel: 'Lab Shot',
      powerDescription: 'removes 2 wrong answers',
      quote: '"Curiosity is my superpower."',
      assetPath: 'assets/characters/hero_harold.png',
      sortOrder: 7,
      unlockStoriesRequired: 2,
      isUnlocked: false,
      isSelected: false,
    ),
    const HeroModel(
      id: 'hero-evelya',
      code: 'EVELYA',
      displayName: 'Evelya',
      roleTitle: 'Reader',
      bulliedFor: 'loving to read',
      powerCode: 'STORY',
      powerLabel: 'Story shot',
      powerDescription:
          "reads the defense like a book, predicts the opponent's next move",
      quote: '"Every chapter makes me stronger."',
      assetPath: 'assets/characters/hero_evelya.png',
      sortOrder: 8,
      unlockStoriesRequired: 2,
      isUnlocked: false,
      isSelected: false,
    ),
  ];

  static List<HeroModel> getHeroes() {
    final activeId = selectedIdOverride ?? 'hero-michele';
    return _defaultHeroes.map((hero) {
      final unlocked = allUnlockedOverride || hero.isUnlocked;
      return hero.copyWith(
        isUnlocked: unlocked,
        isSelected: hero.id == activeId,
      );
    }).toList();
  }

  static HeroModel select(String id) {
    final heroes = getHeroes();
    final target = heroes.firstWhere(
      (h) => h.id == id,
      orElse: () => throw Exception('Hero not found: $id'),
    );
    if (!target.isUnlocked) {
      throw Exception('Cannot select locked hero: $id');
    }
    selectedIdOverride = id;
    return target.copyWith(isSelected: true);
  }

  static HeroModel get selectedHero {
    final heroes = getHeroes();
    return heroes.firstWhere((h) => h.isSelected, orElse: () => heroes[1]);
  }

  static List<HeroModel> get unlockedHeroes {
    return getHeroes().where((h) => h.isUnlocked).toList();
  }

  static void reset() {
    allUnlockedOverride = false;
    selectedIdOverride = null;
  }
}
