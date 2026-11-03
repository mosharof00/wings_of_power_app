import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/modules/game/controllers/game_play_controller.dart';
import 'championship_round_complete_view.dart';

class GameResultsView extends StatelessWidget {
  const GameResultsView({
    super.key,
    this.controller,
  });

  final GamePlayController? controller;

  @override
  Widget build(BuildContext context) {
    final effectiveController = controller ??
        (Get.isRegistered<GamePlayController>()
            ? Get.find<GamePlayController>()
            : null);

    if (effectiveController != null) {
      return ChampionshipRoundCompleteView(controller: effectiveController);
    }

    return const Scaffold(
      body: Center(
        child: Text('No active match results'),
      ),
    );
  }
}

