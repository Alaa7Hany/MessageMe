import 'package:message_me/core/helpers/custom_page_routes.dart';
import 'package:message_me/features/auth/views/pages/login_page.dart';

import '../../features/auth/views/pages/auth_wrapper_page.dart';
import '../../features/auth/views/pages/signup_page.dart';
import '../../features/home/data/models/chat_model.dart';
import '../../features/home/views/pages/home_page.dart';
import '../../features/messages/views/pages/messages_page.dart';
import 'routes.dart';

import 'package:flutter/material.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    //  this arguments to be passed in any screen like this ( arguments as ClassName )
    final arguments = settings.arguments;

    switch (settings.name) {
      // case Routes.onBoardingScreen:
      //   return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case Routes.login:
        return SlideRoute(page: LoginPage());
      case Routes.signup:
        return SlideRoute(page: SignupPage());
      case Routes.authWrapper:
        return FadeRoute(page: AuthWrapper());

      case Routes.messages:
        return SlideRoute(
          page: MessagesPage(chatModel: arguments as ChatModel),
        );

      case Routes.home:
        return FadeRoute(page: const HomePage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
