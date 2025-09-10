import 'package:flutter/material.dart';
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
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.status != MessageStatus.sent)
          Text(
            message.status.name,
            style: AppTextStyles.f12w400secondary().copyWith(color: timeColor),
          ),
        const Spacer(),
        Text(
          formattedTime,
          style: AppTextStyles.f12w400secondary().copyWith(color: timeColor),
        ),
      ],
    );
  }
}
