import 'package:get/get.dart';
import 'package:wings_of_power_app/app/core/network/api_client.dart';
import 'auth_repository.dart';
import 'hero_repository.dart';
import 'home_repository.dart';

class AppRepositoryBinding extends Bindings {
  @override
  void dependencies() {
    // ApiClient — permanent, created immediately, shared by all repositories
    Get.put<ApiClient>(ApiClient(), permanent: true);

    // Repositories — lazy, created only when first Get.find() is called
    Get.lazyPut<IAuthRepository>(
          () => AuthRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<IHeroRepository>(
      () => HeroRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<IHomeRepository>(
      () => HomeRepository(Get.find<ApiClient>()),
      fenix: true,
    );
  }
}
