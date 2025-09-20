// lib/features/messages/views/pages/messages_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:message_me/features/messages/views/widgets/date_label.dart';

import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/my_snackbar.dart';
import '../../../home/logic/chats_cubit/chats_cubit.dart';
import '../widgets/message_bubble.dart';
import '../widgets/send_message_field.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/services/dependency_injection_service.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../auth/logic/auth_cubit/auth_cubit.dart';
import '../../../home/data/models/chat_model.dart';
import '../../logic/messages_cubit/messages_cubit.dart';
import '../../logic/messages_cubit/messages_state.dart';
import '../widgets/messages_appbar.dart';

// Convert to a StatefulWidget
class MessagesPage extends StatefulWidget {
  final ChatModel chatModel;
  const MessagesPage({super.key, required this.chatModel});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  // Store the chatModel in the state
  late ChatModel _chatModel;

  @override
  void initState() {
    super.initState();
    _chatModel = widget.chatModel;
  }

  @override
  Widget build(BuildContext context) {
    final String currentId = AuthCubit.get(context).currentUser!.uid;
    return BlocProvider(
      create: (context) {
        context.read<ChatsCubit>().markChatAsRead(_chatModel.uid);
        // Pass the state's chatModel to the cubit
        return MessagesCubit(getIt(), _chatModel);
      },
      child: Builder(
        builder: (context) {
          final cubit = MessagesCubit.get(context);
          return BlocConsumer<MessagesCubit, MessagesState>(
            listener: (context, state) {
              if (state is MessagesError) {
                MySnackbar.error(context, state.message);
              }
            },
            builder: (context, state) {
              return Scaffold(
                appBar: MessagesAppbar(
                  // Use the state's chatModel for the AppBar
                  chatModel: _chatModel,
                  context: context,
                  onTap: () async {
                    if (_chatModel.isGroup) {
                      final result = await Navigator.pushNamed(
                        context,
                        Routes.groupSettings,
                        arguments: _chatModel,
                      );

                      // Check if we got an updated model back and update the state
                      if (result != null && result is ChatModel) {
                        setState(() {
                          _chatModel = result;
                        });
                      }
                    }
                  },
                ),
                body: SafeArea(
                  child: _buildUi(context, state, currentId, cubit),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUi(
    BuildContext context,
    MessagesState state,
    String currentId,
    MessagesCubit cubit,
  ) {
    if (state is MessagesLoaded) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Column(
          children: [
            // Pass the member count from the state's chat model
            Expanded(
              child: _buildMessagesList(
                state,
                cubit,
                currentId,
                _chatModel.membersIds.length,
              ),
            ),
            SendMessageField(
              controller: cubit.messageController,
              onSendText: () {
                cubit.sendTextMessage();
              },
              onSendImage: () {
                cubit.sendImage();
              },
            ),
          ],
        ),
      );
    } else if (state is MessagesLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentColor),
      );
    } else if (state is MessagesError) {
      return Center(child: Text('Error: ${state.message}'));
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildMessagesList(
    MessagesLoaded state,
    MessagesCubit cubit,
    String currentId,
    int memberCount,
  ) {
    bool isSameDay(DateTime date1, DateTime date2) {
      return date1.year == date2.year &&
          date1.month == date2.month &&
          date1.day == date2.day;
    }

    return state.messages.isNotEmpty
        ? ListView.builder(
            controller: cubit.messagesListViewController,
            reverse: true,
            // Now we use a simple list from the state
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final message = state.messages[index];
              final bool showDateLabel;

              if (index == state.messages.length - 1 ||
                  !isSameDay(
                    message.timeSent,
                    state.messages[index + 1].timeSent,
                  )) {
                showDateLabel = true;
              } else {
                showDateLabel = false;
              }

              return Column(
                children: [
                  if (showDateLabel) DateLabel(dateTime: message.timeSent),
                  MessageBubble(
                    message: message,
                    currentId: currentId,
                    // Pass the member count
                    memberCount: memberCount,
                  ),
                ],
              );
            },
          )
        : Center(
            child: Text(
              'No messages\nBe the first one to say Hi👋',
              style: AppTextStyles.f24w700primary(),
              textAlign: TextAlign.center,
            ),
          );
  }
}
