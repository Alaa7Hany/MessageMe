import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/my_snackbar.dart';
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

class MessagesPage extends StatelessWidget {
  final ChatModel chatModel;
  const MessagesPage({super.key, required this.chatModel});

  @override
  Widget build(BuildContext context) {
    late final MessagesCubit cubit;
    final String currentId = AuthCubit.get(context).currentUser!.uid;
    return BlocProvider(
      create: (context) => MessagesCubit(getIt(), chatModel),
      child: Builder(
        builder: (context) {
          cubit = MessagesCubit.get(context);
          return BlocConsumer<MessagesCubit, MessagesState>(
            listener: (context, state) {
              // Always scroll to the bottom, when a new message arrives
              // context.read<MessagesCubit>().scrollToBottom();
              if (state is MessagesError) {
                MySnackbar.error(context, state.message);
              }
            },
            builder: (context, state) {
              return Scaffold(
                appBar: MessagesAppbar(
                  chatModel: chatModel,
                  context: context,
                  onTap: () async {
                    final result = chatModel.isGroup
                        ? await Navigator.pushNamed(
                            context,
                            Routes.groupSettings,
                            arguments: chatModel,
                          )
                        : null;
                    if (result == true) {
                      cubit.updateChatData();
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
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Column(
          children: [
            Expanded(child: _buildMessagesList(state, cubit, currentId)),
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
  ) {
    return state.messages.isNotEmpty
        ? ListView.builder(
            controller: cubit.messagesListViewController,
            reverse: true,

            itemCount: state.messages.length + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // If it's the last item and we have more to load, show a spinner
              if (index >= state.messages.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      color: AppColors.accentColor,
                    ),
                  ),
                );
              }
              final message = state.messages[index];
              return MessageBubble(message: message, currentId: currentId);
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
