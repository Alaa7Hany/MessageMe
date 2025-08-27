import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:message_me/core/firebase/firebase_keys.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage;

  StorageService(this._storage);

  String _createUniqueImagePath(String uid, File file, String imagePath) {
    // 1. Get the file extension (e.g., ".jpg", ".png").
    final String fileExtension = path.extension(file.path);

    // 2. Create a unique filename using the current timestamp.
    // This prevents uploads from overwriting each other.
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}$fileExtension';

    // 3. Combine the parts into a full path.
    // This organizes files into a folder for each user.
    return '$imagePath/$uid/$fileName';
  }

  Future<String> uploadUserImage(String uid, File file) async {
    // get the umique image path
    final String imagePath = _createUniqueImagePath(
      uid,
      file,
      FirebaseKeys.usersImagesPath,
    );
    // Create a reference to the location to upload to
    final Reference ref = _storage.ref().child(imagePath);

    // Upload the file
    final UploadTask task = ref.putFile(file);
    final TaskSnapshot snapshot = await task;
    // return the URL
    return await snapshot.ref.getDownloadURL();
  }
}
