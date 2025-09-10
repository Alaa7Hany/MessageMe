import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../auth/logic/auth_cubit/auth_cubit.dart';
import 'setting_page.dart';

import '../../../../core/services/dependency_injection_service.dart';
import '../../../auth/data/repo/auth_repo.dart';
import '../../../auth/logic/auth_cubit/auth_state.dart';
import '../../data/repo/chats_repo.dart';
import '../../data/repo/find_users_repo.dart';
import '../../logic/chats_cubit/chats_cubit.dart';
import '../../logic/find_users_cubit/find_users_cubit.dart';
import '../../logic/settings_cubit/settings_cubit.dart';
import 'chats_page.dart';
import 'find_users_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _currentPage = 0;
  final List<Widget> _pages = const [
    ChatsPage(),
    FindUsersPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Start listening to app lifecycle events
    WidgetsBinding.instance.addObserver(this);

    // Set user to 'online' when the HomePage first loads
    context.read<AuthCubit>().updateUserStatus(true);
  }

  @override
  void dispose() {
    // Stop listening to prevent memory leaks
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final authCubit = context.read<AuthCubit>();

    switch (state) {
      case AppLifecycleState.resumed:
        // The app has come to the foreground.
        authCubit.updateUserStatus(true);
        break;
      case AppLifecycleState.detached:
        // The app is being closed.
        authCubit.updateUserStatus(false);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        // The app is in the background, but not closed. Do nothing.
        // The user should still be considered "online".
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // MyLogger.bgMagenta('HomePage, Building HomePage');
    return MultiBlocProvider(
      providers: [
        // BlocProvider<ChatsCubit>(
        //   create: (context) => ChatsCubit(getIt<ChatsRepo>())..loadChats(),
        // ),
        BlocProvider(
          create: (context) => FindUsersCubit(getIt<FindUsersRepo>()),
        ),
        BlocProvider(
          create: (context) =>
              SettingsCubit(getIt<AuthRepo>(), getIt<ChatsRepo>()),
        ),
      ],
      child: Scaffold(
        appBar: _buildAppBar(context),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentPage,
          onTap: (value) {
            setState(() {
              _currentPage = value;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
            BottomNavigationBarItem(
              icon: Icon(Icons.supervised_user_circle),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
        body: IndexedStack(index: _currentPage, children: _pages),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Image.asset(AppAssets.logoWithText, height: 120.h, width: 140.w),
      centerTitle: false,
      automaticallyImplyLeading: false,
      actions: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthLoggedOut) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.login,
                (Route<dynamic> route) => false,
              );
            }
          },
          child: IconButton(
            icon: Icon(
              Icons.logout,
              color: AppColors.primaryTextColor,
              size: 35.h,
            ),
            onPressed: () {
              AuthCubit.get(context).logout();
            },
          ),
        ),
      ],
    );
  }
}
