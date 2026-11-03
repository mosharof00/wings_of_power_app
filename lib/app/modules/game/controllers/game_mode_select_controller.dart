import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/network/api_client.dart';
import 'package:wings_of_power_app/app/data/models/how_to_play.dart';
import 'package:wings_of_power_app/app/data/repositories/game_repository.dart';
import 'package:wings_of_power_app/app/data/repositories/igame_repository.dart';
import 'package:wings_of_power_app/app/modules/home/controllers/home_controller.dart';
import '../views/widgets/game_how_to_play_sheet.dart';

class GameModeSelectController extends GetxController {
  GameModeSelectController([IGameRepository? repository])
      : _repository = repository ??
            (Get.isRegistered<IGameRepository>()
                ? Get.find<IGameRepository>()
                : GameRepository(Get.find<ApiClient>()));

  final IGameRepository _repository;

  /// true = Single Player selected, false = Multi Player selected
  final isSinglePlayer = true.obs;

  final coins = 245.obs;
  final xp = 2.obs;
  final avatarUrl = RxnString();

  @override
  void onInit() {
    super.onInit();
    _loadStudentStats();
  }

  void _loadStudentStats() {
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      final homePoints = homeController.points;
      if (homePoints > 0) {
        coins.value = homePoints;
      }
      avatarUrl.value = homeController.avatarUrl;
    }
  }

  void selectSinglePlayer() {
    isSinglePlayer.value = true;
  }

  void selectMultiPlayer() {
    isSinglePlayer.value = false;
  }

  void onChooseHero() {
    Get.snackbar(
      'Coming Soon',
      'Choose Power Hero will be available in the next release.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFE86726),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> onHowToPlay() async {
    try {
      final howToPlay = await _repository.getHowToPlay();
      await GameHowToPlaySheet.show(howToPlay: howToPlay);
    } catch (_) {
      await GameHowToPlaySheet.show(
        howToPlay: HowToPlayModel(steps: HowToPlayModel.defaultSteps),
      );
    }
  }

  void onHomeTap() {
    Get.back();
  }
}

