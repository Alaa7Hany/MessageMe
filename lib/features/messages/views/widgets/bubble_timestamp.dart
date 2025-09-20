import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/app_text_styles.dart';
import '../../data/models/message_model.dart';

class BubbleTimestamp extends StatelessWidget {
  final MessageModel message;
  final Color timeColor;

  const BubbleTimestamp({
    super.key,
    required this.message,
    required this.timeColor,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedTime = DateFormat('hh:mm a').format(message.timeSent);
    return Row(
      mainAxisSize: MainAxisSize
          .min, // This is important, it keeps the row from expanding
      children: [
        if (message.status != MessageStatus.sent)
          Text(
            message.status.name,
            style: AppTextStyles.f12w400secondary().copyWith(color: timeColor),
          ),

        // Add some space if the status is showing
        if (message.status != MessageStatus.sent) SizedBox(width: 8.w),

        // THE SPACER WAS REMOVED FROM HERE
        Text(
          formattedTime,
          style: AppTextStyles.f12w400secondary().copyWith(color: timeColor),
        ),
      ],
    );
  }
}
