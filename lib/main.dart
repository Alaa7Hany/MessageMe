import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:message_me/core/cubit/connectivity_cubit/connectivity_cubit.dart';
import 'package:message_me/core/services/dependency_injection_service.dart';
import 'package:message_me/core/utils/app_colors.dart';
import 'package:message_me/core/widgets/my_snackbar.dart';
import 'package:message_me/features/auth/logic/auth_cubit/auth_cubit.dart';
import 'package:message_me/features/auth/views/pages/auth_wrapper_page.dart';

import 'core/cubit/connectivity_cubit/connectivity_state.dart';
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
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: getIt<AuthCubit>()),
          BlocProvider.value(value: getIt<ConnectivityCubit>()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MessageMe',
          theme: ThemeData(
            progressIndicatorTheme: ProgressIndicatorThemeData(
              color: AppColors.accentColor,
            ),
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
          home: BlocListener<ConnectivityCubit, ConnectivityState>(
            listenWhen: (previous, current) {
              // This condition prevents the listener from running on the initial check
              // if the app starts with an internet connection.
              if (previous is ConnectivityInitial &&
                  current is ConnectivityConnected) {
                return false;
              }
              return true;
            },
            listener: (context, state) {
              // Hide the offline snackbar when connection is restored
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              if (state is ConnectivityDisconnected) {
                MySnackbar.error(context, 'You Are Offline');
              } else if (state is ConnectivityConnected) {
                MySnackbar.success(context, 'Connection Restored');
              }
            },
            child: AuthWrapper(),
          ),

          // initialRoute: Routes.authWrapper,
          onGenerateRoute: appRouter.generateRoute,
        ),
      ),
    );
  }
}
