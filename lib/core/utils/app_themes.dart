import 'package:flutter/material.dart';
import 'package:message_me/core/utils/app_colors.dart';

class AppThemes {
  AppThemes._();

  static final mainAppTheme = ThemeData(
    progressIndicatorTheme: const ProgressIndicatorThemeData(
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
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.appBarBackground),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.scaffoldBackground,
      selectedItemColor: AppColors.accentColor,
      unselectedItemColor: AppColors.secondaryTextColor,
    ),
  );
}
