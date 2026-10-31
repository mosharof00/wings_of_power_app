import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import 'app/core/config/app_config.dart';
import 'app/core/services/local_store_service.dart';
import 'app/core/theme/app_theme.dart';
import 'app/data/repositories/app_repository_binding.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.initHive();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => GetMaterialApp(
        textDirection: TextDirection.ltr,
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,

        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.light,

        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,

        initialBinding: AppRepositoryBinding(),
      ),
    );
  }
}
