import 'package:get/get.dart';

import '../modules/account_setup/bindings/account_setup_binding.dart';
import '../modules/account_setup/views/account_setup_view.dart';
import '../modules/account_setup/views/pending_approval_view.dart';
import '../modules/achievements/bindings/achievements_binding.dart';
import '../modules/achievements/views/badges_view.dart';
import '../modules/achievements/views/leaderboard_view.dart';
import '../modules/achievements/views/positive_points_view.dart';
import '../modules/achievements/views/reading_progress_view.dart';
import '../modules/game/bindings/game_binding.dart';
import '../modules/game/views/game_mode_select_view.dart';
import '../modules/heroes/bindings/heroes_binding.dart';
import '../modules/heroes/views/character_choose_view.dart';
import '../modules/heroes/views/hero_roster_view.dart';
import '../modules/heroes/views/power_hero_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/safe_space/bindings/safe_space_binding.dart';
import '../modules/safe_space/views/safe_space_form_view.dart';
import '../modules/safe_space/views/safe_space_intro_view.dart';
import '../modules/safe_space/views/safe_space_report_detail_view.dart';
import '../modules/safe_space/views/safe_space_reports_list_view.dart';
import '../modules/safe_space/views/safe_space_submission_success_view.dart';
import '../modules/join_class/bindings/join_class_binding.dart';
import '../modules/join_class/views/join_class_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/main_page/bindings/main_page_binding.dart';
import '../modules/main_page/views/main_page_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/change_password_view.dart';
import '../modules/profile/views/edit_profile_view.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/settings_view.dart';
import '../modules/quiz/bindings/quiz_binding.dart';
import '../modules/quiz/views/chapter_quiz_result_view.dart';
import '../modules/quiz/views/chapter_quiz_view.dart';
import '../modules/quiz/views/checkpoint_quiz_view.dart';
import '../modules/reader/bindings/reader_binding.dart';
import '../modules/reader/views/reader_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/stories/bindings/stories_binding.dart';
import '../modules/stories/views/story_details_view.dart';
import '../modules/stories/views/story_library_view.dart';
import '../modules/stories/views/widgets/stubs.dart';
import '../modules/welcome/bindings/welcome_binding.dart';
import '../modules/welcome/views/welcome_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.MAIN_PAGE,
      page: () => const MainPageView(),
      binding: MainPageBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.WELCOME,
      page: () => const WelcomeView(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: _Paths.JOIN_CLASS,
      page: () => const JoinClassView(),
      binding: JoinClassBinding(),
    ),
    GetPage(
      name: _Paths.ACCOUNT_SETUP,
      page: () => const AccountSetupView(),
      binding: AccountSetupBinding(),
    ),
    GetPage(
      name: _Paths.PENDING_APPROVAL,
      page: () => const PendingApprovalView(),
    ),
    GetPage(
      name: _Paths.CHARACTER_CHOOSE,
      page: () => const CharacterChooseView(),
      binding: HeroesBinding(),
    ),
    GetPage(
      name: _Paths.POWER_HERO,
      page: () => const PowerHeroView(),
      binding: HeroesBinding(),
    ),
    GetPage(
      name: _Paths.HERO_ROSTER,
      page: () => const HeroRosterView(),
      binding: HeroesBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.CHANGE_PASSWORD,
      page: () => const ChangePasswordView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.SAFE_SPACE,
      page: () => const SafeSpaceIntroView(),
      binding: SafeSpaceBinding(),
    ),
    GetPage(
      name: '/safe-space-report',
      page: () => const SafeSpaceIntroView(),
      binding: SafeSpaceBinding(),
    ),
    GetPage(
      name: _Paths.SAFE_SPACE_FORM,
      page: () => const SafeSpaceFormView(),
      binding: SafeSpaceBinding(),
    ),
    GetPage(
      name: _Paths.SAFE_SPACE_DONE,
      page: () => const SafeSpaceSubmissionSuccessView(),
      binding: SafeSpaceBinding(),
    ),
    GetPage(
      name: _Paths.SAFE_SPACE_REPORTS,
      page: () => const SafeSpaceReportsListView(),
      binding: SafeSpaceBinding(),
    ),
    GetPage(
      name: _Paths.SAFE_SPACE_REPORT_DETAIL,
      page: () => const SafeSpaceReportDetailView(),
      binding: SafeSpaceBinding(),
      opaque: false,
    ),
    GetPage(
      name: _Paths.STORY_LIBRARY,
      page: () => const StoryLibraryView(),
      binding: StoriesBinding(),
    ),
    GetPage(
      name: _Paths.STORY_DETAILS,
      page: () => const StoryDetailsView(),
      binding: StoriesBinding(),
    ),
    GetPage(
      name: _Paths.STORY_READER,
      page: () => const ReaderView(),
      binding: ReaderBinding(),
    ),
    GetPage(
      name: _Paths.READER,
      page: () => const ReaderView(),
      binding: ReaderBinding(),
    ),
    GetPage(
      name: _Paths.STORY_LISTENING,
      page: () => const StoryListeningStubView(),
    ),
    GetPage(
      name: _Paths.CHAPTER_QUIZ,
      page: () => const ChapterQuizView(),
      binding: QuizBinding(),
    ),
    GetPage(
      name: _Paths.CHAPTER_QUIZ_RESULT,
      page: () => const ChapterQuizResultView(),
      binding: QuizBinding(),
    ),
    GetPage(
      name: _Paths.CHECKPOINT_QUIZ,
      page: () => const CheckpointQuizView(),
      binding: QuizBinding(),
    ),
    GetPage(
      name: _Paths.BADGES,
      page: () => const BadgesView(),
      binding: AchievementsBinding(),
    ),
    GetPage(
      name: _Paths.POSITIVE_POINTS,
      page: () => const PositivePointsView(),
      binding: AchievementsBinding(),
    ),
    GetPage(
      name: _Paths.LEADERBOARD,
      page: () => const LeaderboardView(),
      binding: AchievementsBinding(),
    ),
    GetPage(
      name: _Paths.READING_PROGRESS,
      page: () => const ReadingProgressView(),
      binding: AchievementsBinding(),
    ),
    GetPage(
      name: _Paths.GAME_MODE_SELECT,
      page: () => const GameModeSelectView(),
      binding: GameBinding(),
    ),
  ];
}
