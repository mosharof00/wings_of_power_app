import 'package:get/get.dart';

import '../modules/account_setup/bindings/account_setup_binding.dart';
import '../modules/account_setup/views/account_setup_view.dart';
import '../modules/account_setup/views/pending_approval_view.dart';
import '../modules/heroes/bindings/heroes_binding.dart';
import '../modules/heroes/views/character_choose_view.dart';
import '../modules/heroes/views/hero_roster_view.dart';
import '../modules/heroes/views/power_hero_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/views/widgets/safe_space_stub_view.dart';
import '../modules/join_class/bindings/join_class_binding.dart';
import '../modules/join_class/views/join_class_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/main_page/bindings/main_page_binding.dart';
import '../modules/main_page/views/main_page_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
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
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.SAFE_SPACE_REPORT,
      page: () => const SafeSpaceStubView(),
    ),
  ];
}
