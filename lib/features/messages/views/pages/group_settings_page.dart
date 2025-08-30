import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:message_me/core/services/dependency_injection_service.dart';
import 'package:message_me/core/utils/app_colors.dart';
import 'package:message_me/core/utils/app_text_styles.dart';
import 'package:message_me/features/auth/data/repo/auth_repo.dart';
import 'package:message_me/features/home/data/models/chat_model.dart';
import 'package:message_me/features/home/logic/settings_cubit/settings_cubit.dart';

import '../../../home/data/repo/chats_repo.dart';
import '../../../home/views/pages/setting_page.dart';

class GroupSettingsPage extends StatelessWidget {
  final ChatModel chatModel;
  const GroupSettingsPage({super.key, required this.chatModel});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(
        getIt<AuthRepo>(),
        getIt<ChatsRepo>(),
        isGroupSettings: true,
        chatModel: chatModel,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Group Settings', style: AppTextStyles.f18w600primary()),
          foregroundColor: AppColors.primaryTextColor,
        ),
        body: SettingsPage(),
      ),
    );
  }
}
