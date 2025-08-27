import 'package:flutter/material.dart';

import '../../../../core/utils/app_text_styles.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Users Page', style: AppTextStyles.f24w700primary()),
    );
  }
}
