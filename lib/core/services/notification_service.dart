import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:message_me/core/firebase/database_service.dart';
import 'package:message_me/core/firebase/firebase_keys.dart';
import 'package:message_me/core/helpers/my_logger.dart';

// This handler must be a top-level function (outside of any class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  MyLogger.green('Handling a background message: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _fcm;
  final DatabaseService _databaseService;

  NotificationService(this._fcm, this._databaseService);

  /// Initializes the notification service by requesting permissions
  /// and setting up message listeners.
  Future<void> initNotifications() async {
    // Request permission from the user (for iOS and modern Android)
    await _fcm.requestPermission();

    // Set up listeners for incoming messages
    _setupListeners();
  }

  /// Gets the unique FCM device token and saves it to the
  /// current user's document in Firestore.
  Future<void> saveTokenToDatabase(String userId) async {
    try {
      // Get the token
      String? token = await _fcm.getToken();
      if (token == null) {
        MyLogger.red('Could not get FCM token.');
        return;
      }
      MyLogger.green('FCM Token: $token');

      // Save the token to the user's document
      await _databaseService.updateData(
        path: '${FirebaseKeys.usersCollection}/$userId',
        // Make sure your UserModel has an 'fcmToken' field
        data: {FirebaseKeys.fcmToken: token},
      );
    } catch (e) {
      MyLogger.red('Error saving FCM token: $e');
    }
  }

  void _setupListeners() {
    // For messages that arrive while the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      MyLogger.green('Got a message whilst in the foreground!');
      // Here you could show a local notification to make sure the user sees it
    });

    // For messages that are tapped when the app is in the background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      MyLogger.green('A new onMessageOpenedApp event was published!');
      // TODO: Handle navigation to the specific chat screen
    });

    // For handling messages when the app is terminated
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}
