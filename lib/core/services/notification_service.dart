import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:message_me/core/firebase/database_service.dart';
import 'package:message_me/core/firebase/firebase_keys.dart';
import 'package:message_me/core/helpers/my_logger.dart';

import '../../features/home/data/models/chat_model.dart';
import '../../features/home/data/repo/chats_repo.dart';
import '../routing/navigation_service.dart';
import '../routing/routes.dart';
import 'dependency_injection_service.dart';

// This handler must be a top-level function (outside of any class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  MyLogger.green('Handling a background message: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _fcm;
  final DatabaseService _databaseService;

  // StreamController to broadcast the chatId
  final _newMessageController = StreamController<String>.broadcast();
  Stream<String> get newMessageStream => _newMessageController.stream;
  void broadcastNewMessage(String chatId) {
    _newMessageController.add(chatId);
  }

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
      MyLogger.yellow('Got a message whilst in the foreground!');
      final chatId = message.data['chatId'];
      if (chatId != null && chatId is String) {
        MyLogger.cyan('New message for chat ID: $chatId. Broadcasting...');
        broadcastNewMessage(chatId);
      }
    });

    // For messages that are tapped when the app is in the background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      MyLogger.yellow('A new onMessageOpenedApp event was published!');

      // Broadcast the message for the UI update (unread marker)
      final chatId = message.data['chatId'];
      if (chatId != null && chatId is String) {
        broadcastNewMessage(chatId);
      }

      // Handle the navigation
      handleMessageNavigation(message);
    });

    // For handling messages when the app is terminated
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> handleMessageNavigation(RemoteMessage message) async {
    final chatId = message.data['chatId'];
    if (chatId == null || chatId is! String) {
      MyLogger.red('Notification data did not contain a valid chatId.');
      return;
    }

    MyLogger.cyan('Handling navigation for chat ID: $chatId');

    // Use GetIt to get instances of your repo and navigation service
    final chatsRepo = getIt<ChatsRepo>();
    final navigationService = getIt<NavigationService>();

    // Fetch the full chat model using the ID
    final ChatModel? chatModel = await chatsRepo.getChatById(chatId);

    if (chatModel != null) {
      // Use the navigation service to push the route
      navigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        Routes.messages,
        ModalRoute.withName(Routes.home),
        arguments: chatModel,
      );
    } else {
      MyLogger.red('Could not find chat with ID: $chatId to navigate.');
    }
  }

  void dispose() {
    _newMessageController.close();
  }
}
