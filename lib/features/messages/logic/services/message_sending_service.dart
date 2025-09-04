import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/models/user_model.dart';
import '../../data/models/message_model.dart';
import '../../data/repo/messages_repo.dart';

class MessageSendingService {
  final MessagesRepo _messagesRepo;
  final String _chatId;
  final UserModel _currentUser;

  MessageSendingService({
    required MessagesRepo messagesRepo,
    required String chatId,
    required UserModel currentUser,
  }) : _messagesRepo = messagesRepo,
       _chatId = chatId,
       _currentUser = currentUser;

  /// Handles the entire text message sending process.
  /// Returns a tuple: (the temporary message for the UI, a future that completes when sent).
  (MessageModel, Future<void>) sendTextMessage(String text) {
    final clientGeneratedId = const Uuid().v4();
    final time = DateTime.now();

    // 1. Create the temporary message for immediate UI display.
    final tempMessage = _createMessageModel(
      uid: clientGeneratedId,
      content: text,
      type: 'text',
      status: MessageStatus.sending,
      time: time,
    );

    // 2. Prepare the final message for Firestore.
    final finalMessage = tempMessage.copyWith(
      uid: null,
      tempId: clientGeneratedId,
      status: MessageStatus.sent,
    );

    // 3. Return the temp message and the future of the send operation.
    return (tempMessage, _messagesRepo.sendMessage(_chatId, finalMessage));
  }

  /// Handles the entire image message sending process.
  Future<(MessageModel, Future<void>)> sendImage() async {
    final PlatformFile file = await _messagesRepo.pickImageFromLibrary();
    final clientGeneratedId = const Uuid().v4();
    final time = DateTime.now();

    // 1. Create the temporary message with the local file path.
    final tempMessage = _createMessageModel(
      uid: clientGeneratedId,
      content: file.path!,
      type: 'image',
      status: MessageStatus.sending,
      time: time,
    );

    // 2. The send operation is now a separate async function.
    final sendFuture = _uploadAndSendFinalImage(
      file: file,
      timeSent: time,
      tempId: clientGeneratedId,
    );

    // 3. Return the temp message and the future.
    return (tempMessage, sendFuture);
  }

  /// Private helper that contains the actual async work for images.
  Future<void> _uploadAndSendFinalImage({
    required PlatformFile file,
    required DateTime timeSent,
    required String tempId,
  }) async {
    final String? imageUrl = await _messagesRepo.uploadImageToStorage(
      _chatId,
      file,
    );
    if (imageUrl == null) {
      throw Exception('Error uploading image, URL was null.');
    }
    final finalMessage = _createMessageModel(
      content: imageUrl,
      type: 'image',
      status: MessageStatus.sent,
      time: timeSent,
    ).copyWith(tempId: tempId);

    await _messagesRepo.sendMessage(_chatId, finalMessage);
  }

  MessageModel _createMessageModel({
    String? uid,
    required String content,
    required String type,
    required MessageStatus status,
    required DateTime time,
  }) {
    return MessageModel(
      uid: uid,
      status: status,
      senderUid: _currentUser.uid,
      senderImage: _currentUser.imageUrl,
      senderName: _currentUser.name,
      type: type,
      content: content,
      timeSent: time,
    );
  }
}
