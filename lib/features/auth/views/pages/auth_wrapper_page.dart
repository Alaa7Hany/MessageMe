import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:message_me/core/extensions/navigation_extensions.dart';
import 'package:message_me/core/utils/app_colors.dart';

import '../../../../core/routing/routes.dart';
import '../../../home/views/pages/home_page.dart';
import '../../logic/auth_cubit/auth_cubit.dart';
import '../../logic/auth_cubit/auth_state.dart';
import 'login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    // Use BlocBuilder to rebuild the UI based on the AuthState
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // When user is logged in, return the HomePage
        if (state is AuthLoginSuccess) {
          return const HomePage();
        }
        // When user is logged out, return the LoginPage
        else if (state is AuthLoggedOut) {
          return const LoginPage();
        }
        // For AuthInitial or any other loading state, show a loading screen.
        // This is the only UI shown until the state is resolved.
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
