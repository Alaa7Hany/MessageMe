import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:message_me/core/extensions/chat_model_presenter.dart';
import 'package:message_me/core/utils/app_text_styles.dart';
import 'package:message_me/core/widgets/my_snackbar.dart';
import 'package:message_me/core/widgets/rounded_image.dart';
import 'package:message_me/features/messages/views/widgets/message_bubble.dart';
import 'package:message_me/features/messages/views/widgets/send_message_field.dart';

import '../../../../core/services/dependency_injection_service.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../auth/logic/auth_cubit/auth_cubit.dart';
import '../../../home/data/models/chat_model.dart';
import '../../logic/messages_cubit/messages_cubit.dart';
import '../../logic/messages_cubit/messages_state.dart';

class MessagesPage extends StatelessWidget {
  final ChatModel chatModel;
  const MessagesPage({super.key, required this.chatModel});

  @override
  Widget build(BuildContext context) {
    final String currentId = AuthCubit.get(context).currentUser!.uid;
    return BlocProvider(
      create: (context) => MessagesCubit(getIt(), chatModel),
      child: Builder(
        builder: (context) {
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
                appBar: _buildAppBar(context),
                body: SafeArea(child: _buildUi(context, state, currentId)),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUi(BuildContext context, MessagesState state, String currentId) {
    final MessagesCubit cubit = MessagesCubit.get(context);
    if (state is MessagesLoaded) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Column(
          children: [
            Expanded(
              child: state.messages.isNotEmpty
                  ? ListView.builder(
                      controller: cubit.messagesListViewController,
                      reverse:
                          true, // Add 1 to the item count for the loading indicator at the top

                      itemCount:
                          state.messages.length + (state.hasMore ? 1 : 0),
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
                        return MessageBubble(
                          message: message,
                          currentId: currentId,
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'No messages\nBe the first one to say Hi👋',
                        style: AppTextStyles.f24w700primary(),
                        textAlign: TextAlign.center,
                      ),
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

  AppBar _buildAppBar(BuildContext context) {
    final String currentId = getIt<AuthCubit>().currentUser!.uid;
    return AppBar(
      toolbarHeight: 50.h,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RoundedImageNetwork(
            radius: 20,
            imageUrl: chatModel.getChatImageUrl(currentId),
          ),
          SizedBox(width: 8.0.w),
          Text(
            chatModel.getChatTitle(currentId),
            style: AppTextStyles.f18w600primary(),
          ),
        ],
      ),
      foregroundColor: AppColors.accentColor,
      actionsPadding: EdgeInsets.zero,
      backgroundColor: AppColors.appBarBackground,
      leadingWidth: 35.w,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, size: 24.w),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
