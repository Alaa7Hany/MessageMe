// lib/main.dart
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:message_me/core/widgets/app_disabled_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'core/routing/navigation_service.dart';
import 'core/services/connectivity_cubit/connectivity_cubit.dart';
import 'core/services/dependency_injection_service.dart';
import 'core/utils/app_themes.dart';
import 'core/widgets/my_snackbar.dart';
import 'features/auth/logic/auth_cubit/auth_cubit.dart';
import 'features/auth/views/pages/auth_wrapper_page.dart';

import 'core/services/connectivity_cubit/connectivity_state.dart';
import 'core/routing/app_router.dart';
import 'features/home/logic/chats_cubit/chats_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // --- Version and Remote Config Logic ---
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      // Set to zero to fetch every time for immediate testing.
      // For a real app, you might set this to Duration(hours: 1).
      minimumFetchInterval: Duration.zero,
    ),
  );
  // Set a default value (an empty JSON) in case the fetch fails.
  await remoteConfig.setDefaults(const {"disabled_versions": "{}"});
  // Fetch the latest values from the Firebase server.
  await remoteConfig.fetchAndActivate();

  // Get the app's package information to find the build number.
  final packageInfo = await PackageInfo.fromPlatform();
  final buildNumber = packageInfo.buildNumber;

  // Get the disabled versions list from Remote Config.
  final disabledVersionsString = remoteConfig.getString('disabled_versions');
  final disabledVersions =
      jsonDecode(disabledVersionsString) as Map<String, dynamic>;

  // Check if the current build number is in the disabled list.
  final bool isThisBuildDisabled = disabledVersions[buildNumber] == true;
  // ------------------------------------

  await setupGetIt();
  runApp(
    MyApp(
      appRouter: AppRouter(),
      // The app is enabled if it is NOT disabled.
      isAppEnabled: !isThisBuildDisabled,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  final bool isAppEnabled;

  const MyApp({super.key, required this.appRouter, required this.isAppEnabled});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: getIt<AuthCubit>()),
          BlocProvider.value(value: getIt<ConnectivityCubit>()),
          BlocProvider.value(value: getIt<ChatsCubit>()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MessageMe',
          theme: AppThemes.mainAppTheme,
          // Conditionally show the main app or the disabled page.
          home: isAppEnabled
              ? BlocListener<ConnectivityCubit, ConnectivityState>(
                  listenWhen: (previous, current) {
                    if (previous is ConnectivityInitial &&
                        current is ConnectivityConnected) {
                      return false;
                    }
                    return true;
                  },
                  listener: (context, state) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    if (state is ConnectivityDisconnected) {
                      MySnackbar.error(context, 'You Are Offline');
                    } else if (state is ConnectivityConnected) {
                      MySnackbar.success(context, 'Connection Restored');
                    }
                  },
                  child: AuthWrapper(),
                )
              : const AppDisabledPage(),
          navigatorKey: getIt<NavigationService>().navigatorKey,
          onGenerateRoute: appRouter.generateRoute,
        ),
      ),
    );
  }
}
