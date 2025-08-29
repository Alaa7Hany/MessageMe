import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:message_me/core/firebase/database_service.dart';
import 'package:message_me/core/firebase/firebase_keys.dart';
import 'package:message_me/core/firebase/storage_service.dart';
import 'package:message_me/core/helpers/my_logger.dart';
import 'package:message_me/core/services/media_service.dart';

import '../../../../core/models/user_model.dart';

class FindUsersRepo {
  final DatabaseService _databaseService;
  final MediaService _mediaService;
  final StorageService _storageService;

  FindUsersRepo(
    this._databaseService,
    this._mediaService,
    this._storageService,
  );

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
}
