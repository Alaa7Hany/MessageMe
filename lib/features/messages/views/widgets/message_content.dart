import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_text_styles.dart';
import '../../data/models/message_model.dart';

class MessageContent extends StatelessWidget {
  final MessageModel message;
  final Color textColor;
  final VoidCallback onImageTap;

  const MessageContent({
    super.key,
    required this.message,
    required this.textColor,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (message.type == 'text') {
      return Text(
        message.content,
        style: AppTextStyles.f16w400primary().copyWith(color: textColor),
      );
    } else if (message.type == 'image') {
      return Container(
        constraints: BoxConstraints(maxHeight: 300.h, maxWidth: 200.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: message.status == MessageStatus.sent
              ? InkWell(
                  onTap: onImageTap,
                  child: Image.network(message.content, fit: BoxFit.cover),
                )
              : Image.file(File(message.content)),
        ),
      );
    }
    // Return an empty widget for unknown types
    return const SizedBox.shrink();
  }
}
