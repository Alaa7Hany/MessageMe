import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:message_me/core/utils/app_text_styles.dart';
import 'package:message_me/core/widgets/rounded_image.dart';
import 'package:message_me/features/messages/data/models/message_model.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/app_colors.dart';

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

    // Define colors based on the sender
    final bubbleColor = isSender
        ? AppColors.accentColor
        : AppColors.appBarBackground;
    final textColor = isSender
        ? AppColors.scaffoldBackground
        : AppColors.primaryTextColor;
    final timeColor = isSender
        ? AppColors.appBarBackground
        : AppColors.secondaryTextColor;

    // Format the timestamp
    final String formattedTime = DateFormat('hh:mm a').format(message.timeSent);

    // Build the message bubble widget
    final bubble = Container(
      // Constrain the bubble's width to be a maximum of 75% of the screen
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.70,
      ),
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
          message.type == 'text'
              ? Text(
                  message.content,
                  style: AppTextStyles.f16w400primary().copyWith(
                    color: textColor,
                  ),
                )
              : Container(
                  constraints: BoxConstraints(
                    maxHeight: 300.h,
                    maxWidth: 200.w,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(message.content, fit: BoxFit.cover),
                  ),
                ),
          SizedBox(height: 5.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              formattedTime,
              style: AppTextStyles.f12w400secondary().copyWith(
                color: timeColor,
              ),
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        // Align content to the start (left) or end (right) of the Row
        mainAxisAlignment: isSender
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        // Align the bottom of the avatar with the bottom of the bubble
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Show the avatar ONLY if the message is from the other person
          if (!isSender) ...[
            RoundedImageNetwork(radius: 20, imageUrl: message.senderImage),
            SizedBox(width: 8.w),
          ],
          bubble,
        ],
      ),
    );
  }
}
