import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/routing/app_router.dart';
import 'core/routing/navigation_service.dart';
import 'core/services/connectivity_cubit/connectivity_cubit.dart';
import 'core/services/connectivity_cubit/connectivity_state.dart';
import 'core/services/dependency_injection_service.dart';
import 'core/utils/app_themes.dart';
import 'core/widgets/app_disabled_page.dart';
import 'core/widgets/my_snackbar.dart';
import 'features/auth/logic/auth_cubit/auth_cubit.dart';
import 'features/auth/views/pages/auth_wrapper_page.dart';
import 'features/home/logic/chats_cubit/chats_cubit.dart';

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
