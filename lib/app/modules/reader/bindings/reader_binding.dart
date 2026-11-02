import 'package:get/get.dart';
import '../../../data/repositories/story_repository.dart';
import '../controllers/reader_controller.dart';

class ReaderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReaderController>(
      () => ReaderController(Get.find<IStoryRepository>()),
    );
  }
}
