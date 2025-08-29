import '../../features/home/data/models/chat_model.dart';

extension ChatModelPresenter on ChatModel {
  /// Gets the title for the chat.
  String getChatTitle(String currentUserId) {
    // If it's a group chat with a name, use that. (Assuming you add a name field later)
    // if (isGroup && name != null) return name!;

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
    if (lastMessageContent != null) {
      return lastMessageType == 'text' ? lastMessageContent! : 'Media message';
    }
    return 'No messages yet';
  }

  /// Gets the appropriate image URL for the chat.
  String? getChatImageUrl(String currentUserId) {
    if (imageUrl != null) {
      return imageUrl;
    }
    if (!isGroup && membersModels.length > 1) {
      // This is now explicit and easier to understand
      final otherUser = membersModels.firstWhere(
        (m) => m.uid != currentUserId,
        orElse: () => membersModels.first, // Fallback is still good to have
      );
      return otherUser.imageUrl;
    }
    return membersModels.isNotEmpty ? membersModels.first.imageUrl : null;
  }

  /// Formats the last active time into a relative string like "5m ago".
  String get formattedLastActive {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (lastMessageContent == null) {
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
