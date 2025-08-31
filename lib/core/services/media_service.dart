import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../helpers/my_logger.dart';

class MediaService {
  Future<PlatformFile?> pickImageFromLibrary() async {
    // 1. Request the photos permission
    final status = await Permission.photos.request();

    // 2. Check the permission status
    if (status.isGranted) {
      // If permission is granted, proceed with picking the file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        return result.files[0];
      }
    } else if (status.isPermanentlyDenied) {
      // If permanently denied, open app settings so the user can manually enable it
      await openAppSettings();
    } else {
      MyLogger.red("Permission denied by user.");
    }

    // 3. Return null if permission is not granted or if the user cancels the picker
    return null;
  }
}
