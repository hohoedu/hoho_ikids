import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/notification/setup_fcm.dart';
import 'package:hani_booki/_core/theme.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/utils/version_check.dart';
import 'package:hive_flutter/hive_flutter.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final screenWidth = MediaQuery.of(Get.context!).size.width;

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('notification_settings');

  await setupFcm();

  // env 로드
  await dotenv.load(fileName: ".env");

  // SecureStorage 초기화
  Get.put(const FlutterSecureStorage());

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [SystemUiOverlay.bottom],
  );

  // Get.put(ConnectivityController);

  // 배경음 셋업
  Get.put(BgmController());
  // 효과음 셋업
  await SoundManager.setupSounds();

  // 화면 가로모드(왼쪽만) 고정
  if (Platform.isIOS) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
  } else {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  Future.delayed(
    const Duration(seconds: 2),
    () {
      FlutterNativeSplash.remove();
    },
  );
  configLoading();
  runApp(const MyApp());
}

void configLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..maskType = EasyLoadingMaskType.black
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBar = MediaQuery.of(context).padding.top;

    return ScreenUtilInit(
      designSize: const Size(360, 722),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.only(top: statusBar),
          child: GetMaterialApp(
            navigatorObservers: [routeObserver],
            debugShowCheckedModeBanner: true,
            theme: theme(),
            initialBinding: BindingsBuilder(
              () async {},
            ),
            // home: const LoginScreen(),
            home: EntryPoint(),
            builder: (context, child) {
              return EasyLoading.init()(
                context,
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: child!,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
