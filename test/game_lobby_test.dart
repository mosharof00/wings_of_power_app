import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/models/game_eligibility.dart';
import 'package:wings_of_power_app/app/data/models/how_to_play.dart';
import 'package:wings_of_power_app/app/data/models/hero_models.dart';
import 'package:wings_of_power_app/app/data/repositories/igame_repository.dart';
import 'package:wings_of_power_app/app/global/widgets/app_scaffold.dart';
import 'package:wings_of_power_app/app/global/widgets/app_sunburst_background.dart';
import 'package:wings_of_power_app/app/modules/game/views/widgets/game_congratulations_dialog.dart';
import 'package:wings_of_power_app/app/modules/game/views/widgets/game_vs_pills.dart';
import 'package:wings_of_power_app/app/modules/game/controllers/game_mode_select_controller.dart';
import 'package:wings_of_power_app/app/modules/game/views/game_mode_select_view.dart';
import 'package:wings_of_power_app/app/modules/game/views/widgets/game_unlock_dialog.dart';

void main() {
  testWidgets('the unlock celebration fills the viewport on the app scaffold', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => MaterialApp(
          home: GameCongratulationsDialog(onPlayNow: () {}, onHowToPlay: () {}),
        ),
      ),
    );
    final burst = find.byType(AppSunburstBackground);
    expect(find.byType(AppScaffold), findsOneWidget);
    expect(tester.getSize(burst), const Size(320, 640));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Play Now'), findsOneWidget);
    expect(find.text('How to Play'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('court score pills fit on a short device with larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.3)),
            child: child!,
          ),
          home: const Scaffold(
            body: GameVsPills(
              teamALabel: 'Team A',
              teamAScore: 33,
              teamBLabel: 'Team B',
              teamBScore: 6,
            ),
          ),
        ),
      ),
    );
    expect(find.text('33'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'locked students can browse the lobby before tapping a play mode',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(() => Get.reset());
      FlutterSecureStorage.setMockInitialValues({'user_id': 'student-test'});
      final repository = _LockedLobbyRepository();
      Get.put(GameModeSelectController(repository));

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, _) => const GetMaterialApp(
            home: GameModeSelectView(embeddedInTab: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'opening the lobby');

      expect(find.text('1 / 2 stories'), findsOneWidget);
      expect(find.text('or 7 / 6 chapters'), findsOneWidget);
      expect(find.text('Quiz average  63.33% / 70%'), findsOneWidget);
      expect(find.byType(GameUnlockDialog), findsNothing);
      expect(find.text('Choose Hero'), findsOneWidget);

      await tester.tap(find.text('How to Play'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'opening How to Play');
      expect(find.text('Choose the play mode'), findsOneWidget);
      Get.back();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Choose Hero'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'opening Choose Hero');
      expect(find.text('Choose Power Hero'), findsOneWidget);
      Get.back();
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Single Player'));
      await tester.tap(find.text('Single Player'));
      await tester.pumpAndSettle();
      expect(find.byType(GameUnlockDialog), findsOneWidget);
      expect(find.text('Continue Reading'), findsOneWidget);
      expect(repository.queueRequests, 0);
      expect(tester.takeException(), isNull);
    },
  );
}

class _LockedLobbyRepository implements IGameRepository {
  int queueRequests = 0;

  @override
  Future<GameEligibilityModel> getEligibility() async => GameEligibilityModel(
    eligible: false,
    progress: GameEligibilityProgress(
      storiesCompleted: 1,
      chaptersCompleted: 7,
      bestQuizPercent: 63.33,
    ),
    rules: GameEligibilityRules(),
  );

  @override
  Future<HowToPlayModel> getHowToPlay() async =>
      HowToPlayModel(steps: HowToPlayModel.defaultSteps);

  @override
  Future<List<HeroModel>> getHeroes() async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #joinQueue) queueRequests++;
    return super.noSuchMethod(invocation);
  }
}
