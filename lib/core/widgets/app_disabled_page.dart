import 'package:flutter/material.dart';
import '../utils/app_text_styles.dart';

class AppDisabledPage extends StatelessWidget {
  const AppDisabledPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'This test version of the app is no longer active. Please contact the developer for a newer version.',
            style: AppTextStyles.f18w600primary(),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
