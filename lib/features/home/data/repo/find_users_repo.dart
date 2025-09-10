import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/database_service.dart';
import '../../../../core/firebase/firebase_keys.dart';
import '../../../../core/helpers/my_logger.dart';
import '../models/chat_model.dart';

import '../../../../core/models/user_model.dart';

class FindUsersRepo {
  final DatabaseService _databaseService;

  FindUsersRepo(this._databaseService);

  Future<List<UserModel>> getUsersPage({
    required String currentUserId,
    int limit = 20,
    UserModel? lastUser,
  }) async {
    try {
      DocumentSnapshot? lastDoc;

      if (lastUser != null) {
        lastDoc = await _databaseService.getDocument(
          path: '${FirebaseKeys.usersCollection}/${lastUser.uid}',
        );
      }
      final String path = FirebaseKeys.usersCollection;
      final snapShot = await _databaseService.getCollection(
        path: path,
        queryBuilder: (query) {
          // configure the base order and filters(don't show the current user)
          var configQuery = query
              .where(FieldPath.documentId, isNotEqualTo: currentUserId)
              .orderBy('name', descending: false);
          // start after bookmark
          if (lastDoc != null) {
            configQuery = configQuery.startAfterDocument(lastDoc);
          }
          // return the final query with the limit
          return configQuery.limit(limit);
        },
      );
      return snapShot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      MyLogger.red('Error fetching users: $e');
      rethrow;
    }
  }

  Future<List<UserModel>> searchUsers({
    required String searchQuery,
    required String currentUserId,
    int limit = 20, // Limit the number of search results
  }) async {
    try {
      // It's best to search on a dedicated, lowercase field.
      final lowercaseQuery = searchQuery.toLowerCase();

      final snapshot = await _databaseService.getCollection(
        path: FirebaseKeys.usersCollection,
        queryBuilder: (query) => query
            .orderBy(FirebaseKeys.nameToLowercase)
            .where(
              FirebaseKeys.nameToLowercase,
              isGreaterThanOrEqualTo: lowercaseQuery,
            )
            .where(
              FirebaseKeys.nameToLowercase,
              isLessThanOrEqualTo: '$lowercaseQuery\uf8ff',
            )
            .where(FieldPath.documentId, isNotEqualTo: currentUserId)
            .limit(limit),
      );

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      MyLogger.red('Error searching users: $e');
      rethrow;
    }
  }

  Future<ChatModel> createOrGetChat(
    UserModel currentUser,
    List<UserModel> selectedUsers,
  ) async {
    final otherMemberIds = selectedUsers.map((user) => user.uid).toList();
    final allMemberIds = [currentUser.uid, ...otherMemberIds];

    // VERY IMPORTANT: Always sort member IDs for consistent chat identification
    // (Will create a group chat of the same people)
    allMemberIds.sort();

    try {
      final snapshot = await _databaseService.getCollection(
        path: FirebaseKeys.chatsCollection,
        queryBuilder: (query) =>
            query.where(FirebaseKeys.members, isEqualTo: allMemberIds).limit(1),
      );

      // If a chat exists, fetch its full data
      if (snapshot.docs.isNotEmpty) {
        MyLogger.yellow('Chat already exists. Fetching chat model.');
        final doc = snapshot.docs.first;
        final chat = ChatModel.fromJson(doc.data());
        chat.uid = doc.id;
        chat.membersModels = [currentUser, ...selectedUsers];
        return chat;
      }
      // If no chat exists, create a new one
      else {
        MyLogger.yellow('No existing chat found. Creating a new one...');

        //  Create an initial unread_counts map with all members set to 0.
        final Map<String, int> initialUnreadCounts = {
          for (var memberId in allMemberIds) memberId: 0,
        };

        // 1. Define the base data for the chat.
        final Map<String, dynamic> baseChatData = {
          FirebaseKeys.members: allMemberIds,
          FirebaseKeys.name: '',
          FirebaseKeys.lastMessageContent: '',
          FirebaseKeys.lastMessageType: '',
          FirebaseKeys.imageUrl: '',
          FirebaseKeys.isGroup: selectedUsers.length > 1,
          FirebaseKeys.unreadCounts: initialUnreadCounts,
        };

        // 2. Send the data to Firestore using the server timestamp instruction.
        final docRef = await _databaseService.addData(
          collectionPath: FirebaseKeys.chatsCollection,
          data: {
            ...baseChatData,
            FirebaseKeys.lastActive: FieldValue.serverTimestamp(),
            FirebaseKeys.createdAt: FieldValue.serverTimestamp(),
          },
        );

        // 3. Construct the local model for immediate use with a client-side timestamp.
        //    This avoids the type error.
        final newChat = ChatModel.fromJson({
          ...baseChatData,
          // Use a real, local Timestamp object here
          FirebaseKeys.lastActive: Timestamp.now(),
          FirebaseKeys.createdAt: Timestamp.now(),
        });

        newChat.uid = docRef.id;
        newChat.membersModels = [currentUser, ...selectedUsers];
        return newChat;
      }
    } catch (e) {
      MyLogger.red('Error creating or getting chat in ChatsRepo: $e');
      rethrow;
    }
  }
}
