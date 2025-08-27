import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:message_me/core/services/dependency_injection_service.dart';
import 'package:message_me/core/utils/app_colors.dart';
import 'package:message_me/features/auth/logic/auth_cubit/auth_cubit.dart';

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
      child: BlocProvider.value(
        value: GetIt.instance<AuthCubit>(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MessageMe',
          theme: ThemeData(
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: AppColors.accentColor,
              selectionColor: AppColors.accentColor,
              selectionHandleColor: AppColors.accentColor,
            ),
            splashColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,

            scaffoldBackgroundColor: AppColors.scaffoldBackground,
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.appBarBackground,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: AppColors.scaffoldBackground,
              selectedItemColor: AppColors.accentColor,
              unselectedItemColor: AppColors.secondaryTextColor,
            ),
          ),
          initialRoute: Routes.login,
          onGenerateRoute: appRouter.generateRoute,
        ),
      ),
    );
  }
}
