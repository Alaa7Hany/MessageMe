import '../../features/home/data/models/chat_model.dart';

extension ChatModelPresenter on ChatModel {
  /// Gets the title for the chat.
  String getChatTitle(String currentUserId) {
    // If it's a group chat with a name, use that. (Assuming you add a name field later)
    // if (isGroup && name != null) return name!;

    if (name != null && name!.isNotEmpty) {
      return name!;
    }

    final otherMembers = membersModels.where(
      (user) => user.uid != currentUserId,
    );
    if (otherMembers.isEmpty) {
      return 'Unknown';
    } else if (otherMembers.length == 1) {
      return otherMembers.first.name;
    }
    return otherMembers.map((user) => user.name.split(' ').first).join(', ');
  }

  /// Gets the subtitle, which is the content of the last message.
  String get subtitle {
    if (lastMessageContent != null && lastMessageContent!.isNotEmpty) {
      final content = lastMessageType == 'text'
          ? lastMessageContent!
          : 'Media message';
      return content;
    }
    return 'No messages yet';
  }

  /// Gets the appropriate image URL for the chat.
  String? getChatImageUrl(String currentUserId) {
    // 1. Handle group chats first.
    if (isGroup) {
      // If the group has a custom image, always prioritize it.
      if (imageUrl != null && imageUrl!.isNotEmpty) {
        return imageUrl;
      }
      // Fallback for a group chat without a custom image (e.g., show first member's avatar).
      return null;
    }

    // 2. Handle 1-on-1 chats. Assumes `membersModels` has two users.
    if (membersModels.length == 2) {
      // Directly find the other user without iterating.
      // If the first user in the list is the current user, return the second's image.
      if (membersModels[0].uid == currentUserId) {
        return membersModels[1].imageUrl;
      }
      // Otherwise, the other user must be the first one in the list.
      return membersModels[0].imageUrl;
    }

    // 3. A final fallback for any unexpected edge cases.
    return null;
  }

  /// Formats the last active time into a relative string like "5m ago".
  String get formattedLastActive {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (lastMessageContent == null || lastMessageContent!.isEmpty) {
      return '';
    }

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'Just now';
  }

  bool isActive(String currentUserId) {
    for (var member in membersModels) {
      if (member.uid != currentUserId) {
        return member.isOnline;
      }
    }
    return false;
  }
}
