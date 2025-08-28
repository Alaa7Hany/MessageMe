import 'package:flutter/material.dart';
import 'package:message_me/core/services/dependency_injection_service.dart';
import 'package:message_me/features/auth/logic/auth_cubit/auth_cubit.dart';
import 'package:message_me/features/auth/views/widgets/rounded_image.dart';

import '../../../../core/utils/app_text_styles.dart';
import '../../data/models/chat_model.dart';

class ChatListtile extends StatelessWidget {
  final ChatModel chatModel;
  const ChatListtile({super.key, required this.chatModel});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _getChatImageUrl() != null
          ? RoundedImageNetwork(radius: 30, imageUrl: _getChatImageUrl()!)
          : const RoundedImageFile(radius: 30),
      title: Text(
        _getChatTitle(),
        style: AppTextStyles.f16w500primary(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _getChatSubtitle(),
        style: AppTextStyles.f14w400secondary(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatLastActive(chatModel.lastActive),
        style: AppTextStyles.f12w400secondary(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _getChatTitle() {
    List<String> members = [];
    for (var participant in chatModel.membersModels) {
      if (participant.uid != getIt<AuthCubit>().currentUser!.uid) {
        members.add(participant.name.split(' ').first);
      }
    }
    return members.isNotEmpty ? members.join(', ') : 'Unknown';
  }

  String _getChatSubtitle() {
    if (chatModel.lastMessage != null) {
      return chatModel.lastMessage!.content;
    }
    return 'No messages yet';
  }

  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'Just now';
  }

  String? _getChatImageUrl() {
    if (chatModel.imageUrl != null) {
      return chatModel.imageUrl;
    } else if (chatModel.membersModels.isNotEmpty) {
      return chatModel.membersModels.first.imageUrl;
    }
    return null;
  }
}
