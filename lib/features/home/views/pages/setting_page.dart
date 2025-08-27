import 'package:flutter/material.dart';

import '../../../../core/utils/app_text_styles.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Settings Page', style: AppTextStyles.f24w700primary()),
    );
  }
}
