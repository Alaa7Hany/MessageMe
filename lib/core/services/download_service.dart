import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../helpers/my_logger.dart';

class DownloadService {
  Future<bool> downloadAndSaveImage(String imageUrl) async {
    try {
      // 1. Request necessary permissions
      PermissionStatus status;
      if (Platform.isAndroid) {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        // On Android 13+, use the 'photos' permission. Otherwise, use 'storage'.
        if (deviceInfo.version.sdkInt >= 33) {
          status = await Permission.photos.request();
        } else {
          status = await Permission.storage.request();
        }
      } else {
        // For iOS
        status = await Permission.photos.request();
      }

      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
        throw Exception('Storage permission was not granted.');
      }

      // 2. Download the image as raw bytes from the URL
      MyLogger.cyan('Downloading image bytes from: $imageUrl');
      final response = await Dio().get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final Uint8List bytes = Uint8List.fromList(response.data);

      // 3. Save the image bytes to the device's gallery
      MyLogger.cyan('Saving image to gallery...');
      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        name: 'MessageMe_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Check the result from the plugin
      if (result['isSuccess'] == true) {
        MyLogger.green('Image saved successfully to: ${result['filePath']}');
        return true;
      } else {
        throw Exception('Failed to save image: ${result['errorMessage']}');
      }
    } catch (e) {
      MyLogger.red('Error downloading and saving image: $e');
      return false;
    }
  }
}
