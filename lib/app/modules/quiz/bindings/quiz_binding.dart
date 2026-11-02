import 'package:get/get.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../controllers/quiz_controller.dart';

class QuizBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuizController>(
      () => QuizController(Get.find<IQuizRepository>()),
    );
  }
}
