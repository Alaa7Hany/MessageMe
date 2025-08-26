import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:message_me/core/di/dependency_injection.dart';
import 'package:message_me/core/utils/app_colors.dart';

import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupGetIt();
  runApp(MyApp(appRouter: AppRouter()));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MessageMe',
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.scaffoldBackground,
          appBarTheme: AppBarTheme(backgroundColor: AppColors.appBarBackground),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: AppColors.scaffoldBackground,
            selectedItemColor: AppColors.accentColor,
            unselectedItemColor: AppColors.secondaryTextColor,
          ),
        ),
        initialRoute: Routes.login,
        onGenerateRoute: appRouter.generateRoute,
      ),
    );
  }
}
