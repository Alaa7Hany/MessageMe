import 'package:flutter/material.dart';
import 'package:message_me/core/utils/app_text_styles.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Chats Pag', style: AppTextStyles.f24w700primary()),
    );
  }
}
