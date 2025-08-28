import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:message_me/core/extensions/navigation_extensions.dart';
import 'package:message_me/core/utils/app_colors.dart';

import '../../../../core/routing/routes.dart';
import '../../logic/auth_cubit/auth_cubit.dart';
import '../../logic/auth_cubit/auth_state.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoginSuccess) {
          // User is logged in, go to home
          context.pushReplacementNamed(Routes.home);
        } else if (state is AuthInitial || state is AuthLoggedOut) {
          // User is logged out, go to login
          context.pushReplacementNamed(Routes.login);
        }
      },
      // While we wait for a state, just show a loading indicator
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentColor),
        ),
      ),
    );
  }
}
