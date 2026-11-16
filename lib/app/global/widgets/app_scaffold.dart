import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart' as mui;

import '../../core/theme/app_color.dart';
import '../../core/theme/app_gradients.dart';

/// Product scaffold: transparent Material surface over the shared gradient.
///
/// Body is wrapped in [mui.Material] so widgets from `package:material_ui`
/// (e.g. pinput 7.x) can resolve a Material ancestor while the app still uses
/// `package:flutter/material.dart` for routes and theme.
///
/// Use [AppBackgroundKind.app] everywhere except game-show flows.
/// Full-bleed art screens (onboarding, splash) can still paint images on top.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.drawer,
    this.endDrawer,
    this.resizeToAvoidBottomInset,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.background = AppBackgroundKind.app,
    this.systemOverlayStyle,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final AppBackgroundKind background;
  final SystemUiOverlayStyle? systemOverlayStyle;

  @override
  Widget build(BuildContext context) {
    final overlay = systemOverlayStyle ??
        (background == AppBackgroundKind.game
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: AppGradients.of(background)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar,
          body: Localizations.override(
            context: context,
            delegates: mui.GlobalMaterialLocalizations.delegates,
            child: mui.Material(
              type: mui.MaterialType.transparency,
              child: body,
            ),
          ),
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
          bottomSheet: bottomSheet,
          drawer: drawer,
          endDrawer: endDrawer,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          extendBody: extendBody,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
        ),
      ),
    );
  }
}

/// Optional page wrapper when a screen already owns a [Scaffold] but still
/// needs the shared gradient behind a transparent scaffold color.
class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({
    super.key,
    required this.child,
    this.kind = AppBackgroundKind.app,
  });

  final Widget child;
  final AppBackgroundKind kind;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.of(kind),
        color: kind == AppBackgroundKind.app ? AppColor.skyTop : null,
      ),
      child: child,
    );
  }
}
