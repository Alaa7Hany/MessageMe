import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:message_me/core/helpers/extensions.dart';
import 'package:message_me/core/utils/app_text_styles.dart';

import '../../../../core/routing/routes.dart';

class AuthFooter extends StatelessWidget {
  final bool inLogin;
  const AuthFooter({super.key, required this.inLogin});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: inLogin ? "Don't have an account? " : "Already have an account? ",
        style: AppTextStyles.f12w400secondary(),
        children: [
          TextSpan(
            text: inLogin ? 'Sign Up' : 'Log In',
            style: AppTextStyles.f14w600accent(),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                inLogin
                    ? context.pushReplacementNamed(Routes.signup)
                    : context.pushReplacementNamed(Routes.login);
              },
          ),
        ],
      ),
    );
  }
}
