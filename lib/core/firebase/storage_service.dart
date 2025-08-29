import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:message_me/core/firebase/firebase_keys.dart';
import 'package:message_me/core/helpers/my_logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class StorageService {
  // It's often simpler to get the instance directly
  final FirebaseStorage _storage;
  final _uuid = Uuid();

  StorageService(this._storage);

  /// Creates a unique path for the image in Firebase Storage.
  /// Note: The 'File' object is no longer needed, just the extension.
  String _createUniqueImagePath(
    String uid,
    String fileExtension,
    String imagePath,
  ) {
    final String fileName = '${_uuid.v4()}$fileExtension';
    return '$imagePath/$uid/$fileName';
  }

  /// Compresses the image file to reduce size.
  Future<File?> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final fileExtension = path.extension(file.path);
    final targetPath = '${tempDir.absolute.path}/${_uuid.v4()}$fileExtension';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 85,
    );

    if (result == null) return null;
    return File(result.path);
  }

  /// Private method to handle the core upload logic.
  Future<String?> _uploadFile(String uid, File file, String storagePath) async {
    // Step 1: Compress the image
    final compressedFile = await _compressImage(file);
    if (compressedFile == null) {
      MyLogger.red('Error: Image compression failed.');
      return null;
    }

    // Step 2: Create a unique path for the file
    final fileExtension = path.extension(compressedFile.path);
    final String imagePath = _createUniqueImagePath(
      uid,
      fileExtension,
      storagePath,
    );

    // Step 3: Upload the compressed file
    final Reference ref = _storage.ref().child(imagePath);
    final UploadTask task = ref.putFile(compressedFile);
    final TaskSnapshot snapshot = await task;

    // Step 4: Return the download URL
    return await snapshot.ref.getDownloadURL();
  }

  /// Uploads a user's profile image.
  Future<String?> uploadUserImage(String uid, File file) async {
    return _uploadFile(uid, file, FirebaseKeys.usersImagesPath);
  }

  /// Uploads an image for a chat.
  Future<String?> uploadChatImage(String chatUid, File file) async {
    return _uploadFile(chatUid, file, FirebaseKeys.chatsImagesPath);
  }
}
