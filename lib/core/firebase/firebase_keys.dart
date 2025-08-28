class FirebaseKeys {
  FirebaseKeys._();

  // Collections
  static const String usersCollection = 'Users';
  static const String messagesCollection = 'Messages';
  static const String chatsCollection = 'Chats';

  // Images Pathes
  static const String usersImagesPath = 'images/users_images';

  // User Model Keys
  static const String uid = 'uid';
  static const String name = 'name';
  static const String email = 'email';
  static const String imageUrl = 'image_url';
  static const String lastActive = 'last_active';

  // Chat Model Keys
  static const String isGroup = 'is_group';
  static const String members = 'members';
  static const String lastMessage = 'last_message';
  static const String createdAt = 'created_at';

  // Message Model Keys
  static const String content = 'content';
  static const String senderUid = 'sender_uid';
  static const String senderName = 'sender_name';
  static const String senderImage = 'sender_image';
  static const String timeSent = 'time_sent';
  static const String type = 'type';
}
