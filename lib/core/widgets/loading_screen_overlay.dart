import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class LoadingScreenOverlay extends StatelessWidget {
  const LoadingScreenOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.transparent.withAlpha(100)),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.accentColor),
      ),
    );
  }
}
