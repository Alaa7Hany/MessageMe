import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/services/dependency_injection_service.dart';
import '../../../../core/services/download_service.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/rounded_image.dart';
import '../../data/models/message_model.dart';
import '../../logic/messages_cubit/messages_cubit.dart';
import 'bubble_timestamp.dart';
import 'message_content.dart';
import 'reaction_picker.dart';
import 'reactions_view.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final String currentId;

  const MessageBubble({
    super.key,
    required this.message,
    required this.currentId,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSender = currentId == message.senderUid;
    final cubit = context.read<MessagesCubit>();

    final bubbleColor = isSender
        ? (message.status == MessageStatus.failed
              ? AppColors.error.withAlpha(60)
              : message.status == MessageStatus.sending
              ? AppColors.accentColor.withAlpha(60)
              : AppColors.accentColor)
        : AppColors.appBarBackground;
    final textColor = isSender
        ? AppColors.scaffoldBackground
        : AppColors.primaryTextColor;
    final timeColor = isSender
        ? AppColors.appBarBackground
        : AppColors.secondaryTextColor;

    // The bubble widget itself remains unchanged.
    final bubble = GestureDetector(
      onLongPress: () => _showReactionPicker(context, cubit, message.uid!),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isSender
                    ? const Radius.circular(16)
                    : const Radius.circular(0),
                bottomRight: isSender
                    ? const Radius.circular(0)
                    : const Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MessageContent(
                  message: message,
                  textColor: textColor,
                  onImageTap: () => _showImageOptions(context, message.content),
                ),
                SizedBox(height: 5.h),
                BubbleTimestamp(message: message, timeColor: timeColor),
              ],
            ),
          ),
          if (message.reactions.isNotEmpty)
            Positioned(
              bottom: -10.h,
              right: isSender ? null : 10.w,
              left: isSender ? 10.w : null,
              child: ReactionsView(reactions: message.reactions),
            ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 4.h,
      ).copyWith(bottom: message.reactions.isNotEmpty ? 18.h : 4.h),
      child: Row(
        mainAxisAlignment: isSender
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSender) ...[
            RoundedImageNetwork(radius: 20, imageUrl: message.senderImage),
            SizedBox(width: 8.w),
          ],
          // **THE FIX:** Wrap the bubble in a Container with constraints.
          // This prevents both the overflow error and the full-width expansion.
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: bubble,
          ),
        ],
      ),
    );
  }

  // ... (_showImageOptions and _showReactionPicker methods are unchanged)
  void _showImageOptions(BuildContext context, String imageUrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.appBarBackground,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.download,
                  color: AppColors.accentColor,
                ),
                title: Text(
                  'Download Image',
                  style: AppTextStyles.f16w400primary(),
                ),
                onTap: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(
                    bottomSheetContext,
                  );
                  final navigator = Navigator.of(bottomSheetContext);

                  navigator.pop();

                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Downloading image...')),
                  );

                  final downloadService = getIt<DownloadService>();
                  final success = await downloadService.downloadAndSaveImage(
                    imageUrl,
                  );

                  scaffoldMessenger.hideCurrentSnackBar();

                  if (success) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Image saved to gallery!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Failed to save image.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReactionPicker(
    BuildContext context,
    MessagesCubit cubit,
    String messageId,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: ReactionPicker(
            onReactionSelected: (reaction) {
              final currentReaction =
                  message.reactions[cubit.currentUser.uid] ?? '';
              final newReaction = currentReaction == reaction ? '' : reaction;

              cubit.reactToMessage(messageId, newReaction);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}
