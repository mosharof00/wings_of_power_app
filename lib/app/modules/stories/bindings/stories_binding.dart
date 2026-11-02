import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/repositories/story_repository.dart';
import '../controllers/stories_controller.dart';

class StoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoriesController>(
      () => StoriesController(Get.find<IStoryRepository>()),
      fenix: true,
    );
  }
}
