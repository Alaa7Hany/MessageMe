import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../helpers/my_logger.dart';

class MediaService {
  // Define the max file size in bytes (5MB)
  static const int _maxFileSizeInBytes = 5 * 1024 * 1024;

  Future<PlatformFile?> pickImageFromLibrary() async {
    PermissionStatus status;

    // Check the Android version and request the appropriate permission
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 33) {
        // Android 13 (API 33) and above
        status = await Permission.photos.request();
      } else {
        // Older Android versions
        status = await Permission.storage.request();
      }
    } else {
      // For iOS or other platforms
      status = await Permission.photos.request();
    }

    // Check the permission status
    if (status.isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // FILE SIZE CHECK
        if (file.size > _maxFileSizeInBytes) {
          // Get the file size in MB for the error message
          final sizeInMb = (file.size / (1024 * 1024)).toStringAsFixed(2);
          throw Exception(
            'File is too large ($sizeInMb MB). Please select a file smaller than 5 MB.',
          );
        }

        return file;
      }
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      MyLogger.red("Permission denied by user.");
    }

    return null;
  }
}
