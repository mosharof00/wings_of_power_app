import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/theme/app_theme.dart';
import 'package:wings_of_power_app/app/core/utils/dialog_utils.dart';
import 'package:wings_of_power_app/app/global/widgets/error_block.dart';
import 'package:wings_of_power_app/app/global/widgets/global_button.dart';
import 'package:wings_of_power_app/app/global/widgets/linear_progress_bar.dart';
import 'package:wings_of_power_app/app/global/widgets/points_chip.dart';
import 'package:wings_of_power_app/app/global/widgets/search_field.dart';
import 'package:wings_of_power_app/app/global/widgets/show_empty_result.dart';
import 'package:wings_of_power_app/app/global/widgets/step_progress.dart';
import 'package:wings_of_power_app/app/global/widgets/student_bottom_nav.dart';
import 'package:wings_of_power_app/app/modules/main_page/controllers/main_page_controller.dart';
import 'package:wings_of_power_app/app/global/widgets/app_input_text_form_field.dart';

Future<void> pumpApp(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => GetMaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  test('basketball nav tap does not change the tab', () {
    final controller = MainPageController();
    addTearDown(controller.dispose);
    controller.onNavTap(1);
    expect(controller.selectedIndex.value, 1);
    controller.onNavTap(2);
    expect(controller.selectedIndex.value, 1);
    controller.onNavTap(4);
    expect(controller.selectedIndex.value, 4);
  });

  testWidgets('primary button respects disabled and loading', (tester) async {
    var taps = 0;
    await pumpApp(
      tester,
      Column(
        children: [
          GlobalButton(text: 'Go', onTap: () => taps++),
          GlobalButton(text: 'Off', isDisabled: true, onTap: () => taps++),
          GlobalButton(
            key: const Key('loading'),
            text: 'Wait',
            isLoading: true,
            onTap: () => taps++,
          ),
          const GlobalButton(
            text: 'Stay',
            variant: GlobalButtonVariant.secondary,
            onTap: _noop,
          ),
        ],
      ),
    );

    await tester.tap(find.text('Go'));
    await tester.tap(find.text('Off'));
    await tester.tap(find.byKey(const Key('loading')));
    expect(taps, 1);
    expect(find.text('Stay'), findsOneWidget);
  });

  testWidgets('points chip shows the count', (tester) async {
    await pumpApp(tester, const PointsChip(count: 12));
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('progress reports 0 and a partial value', (tester) async {
    await pumpApp(
      tester,
      const Column(
        children: [
          LinearProgressBar(value: 0),
          LinearProgressBar(value: 0.4),
        ],
      ),
    );
    expect(find.bySemanticsLabel('Progress'), findsWidgets);
    expect(find.text('0%'), findsNothing);
  });

  testWidgets('step progress builds dots and stars', (tester) async {
    await pumpApp(
      tester,
      const Column(
        children: [
          StepProgress(count: 4, index: 0),
          StepProgress(count: 3, index: 2, style: StepProgressStyle.stars),
        ],
      ),
    );
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
  });

  testWidgets('search field and password field', (tester) async {
    await pumpApp(
      tester,
      const Column(
        children: [
          SearchField(),
          PasswordInputField(label: 'Password', hintText: 'Password'),
        ],
      ),
    );
    expect(find.text('Search'), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField).last);
    expect(field.obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();
    final shown = tester.widget<TextField>(find.byType(TextField).last);
    expect(shown.obscureText, isFalse);
  });

  testWidgets('nav selects home and profile and ignores basketball', (
    tester,
  ) async {
    var selected = 0;
    await pumpApp(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          return StudentBottomNav(
            selectedIndex: selected,
            onTap: (index) => setState(() {
              if (index == 2) return;
              selected = index;
            }),
          );
        },
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Home')).flagsCollection.isSelected,
      Tristate.isTrue,
    );
    await tester.tap(find.byKey(const Key('nav-profile')));
    await tester.pump();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Profile')).flagsCollection.isSelected,
      Tristate.isTrue,
    );
    await tester.tap(find.byKey(const Key('nav-game')));
    await tester.pump();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Profile')).flagsCollection.isSelected,
      Tristate.isTrue,
    );
  });

  testWidgets('empty and error blocks', (tester) async {
    var retried = false;
    await pumpApp(
      tester,
      Column(
        children: [
          const ShowEmptyResult(title: 'No stories yet'),
          ErrorBlock(
            message: 'Could not load stories',
            onRetry: () => retried = true,
          ),
        ],
      ),
    );
    expect(find.text('No stories yet'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retried, isTrue);
  });

  testWidgets('confirm sheet shows title and both actions', (tester) async {
    await pumpApp(
      tester,
      Builder(
        builder: (context) => GlobalButton(
          text: 'Open',
          onTap: () => DialogUtils.showDialog(
            context: context,
            title: 'Leaving Already?',
            description: "Don't worry, your progress is saved.",
            okText: 'Stay',
            cancelText: 'Log out',
            okOnPress: () {},
            cancelOnPress: () {},
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Leaving Already?'), findsOneWidget);
    expect(find.text('Stay'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
  });
}

void _noop() {}
