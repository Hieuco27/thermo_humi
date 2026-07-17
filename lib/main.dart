import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:thermo_humi/core/router/app_router.dart';
import 'package:thermo_humi/core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: "assets/env/.env");
  } catch (e) {}

  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Thermo Humi',
          themeMode: ThemeMode.light,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        );
      },
      child: Container(),
    );
  }
}
