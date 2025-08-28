import 'package:message_me/features/messages/data/models/message_model.dart';

abstract class MessagesState {}

class MessagesInitial extends MessagesState {}

class MessagesLoading extends MessagesState {}

class MessagesLoaded extends MessagesState {
  final List<MessageModel> messages;

  MessagesLoaded(this.messages);
}

class MessagesError extends MessagesState {
  final String message;

  MessagesError(this.message);
}
