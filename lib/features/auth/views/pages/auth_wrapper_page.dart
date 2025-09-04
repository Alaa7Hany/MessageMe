import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:message_me/core/widgets/loading_screen_overlay.dart';

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
        else {
          return const LoginPage();
        }
      },
    );
  }
}
