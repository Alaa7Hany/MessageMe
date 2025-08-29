import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:message_me/core/extensions/navigation_extensions.dart';
import 'package:message_me/core/routing/routes.dart';
import 'package:message_me/core/utils/app_assets.dart';
import 'package:message_me/core/utils/app_colors.dart';
import 'package:message_me/features/auth/logic/auth_cubit/auth_cubit.dart';
import 'package:message_me/features/home/views/pages/setting_page.dart';

import '../../../../core/services/dependency_injection_service.dart';
import '../../../auth/logic/auth_cubit/auth_state.dart';
import '../../data/repo/chats_repo.dart';
import '../../data/repo/find_users_repo.dart';
import '../../logic/chats_cubit/chats_cubit.dart';
import '../../logic/find_users_cubit/find_users_cubit.dart';
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
    SettingPage(),
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
  Widget build(BuildContext context) {
    // MyLogger.bgMagenta('HomePage, Building HomePage');
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatsCubit>(
          create: (context) => ChatsCubit(getIt<ChatsRepo>())..loadChats(),
        ),
        BlocProvider(
          create: (context) =>
              FindUsersCubit(getIt<FindUsersRepo>())..loadInitialUsersPage(),
        ),
      ],
      child: Scaffold(
        appBar: buildAppBar(context),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentPage,
          onTap: (value) {
            setState(() {
              _currentPage = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.supervised_user_circle),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
        body: IndexedStack(index: _currentPage, children: _pages),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Image.asset(AppAssets.logoWithText, scale: 7.h),
      centerTitle: false,
      automaticallyImplyLeading: false,
      actions: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthLoggedOut) {
              context.pushReplacementNamed(Routes.login);
            }
          },
          child: IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primaryTextColor),
            onPressed: () {
              AuthCubit.get(context).logout();
            },
          ),
        ),
      ],
    );
  }
}
