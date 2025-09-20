// lib/features/messages/views/widgets/message_content.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
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
      // Text bubbles naturally adapt their size, so no change is needed here.
      return Text(
        message.content,
        style: AppTextStyles.f16w400primary().copyWith(color: textColor),
      );
    } else if (message.type == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: message.status == MessageStatus.sent
            ? InkWell(
                onTap: onImageTap,
                child: Image.network(
                  message.content,
                  fit: BoxFit.cover,
                  // The loading builder shows a placeholder while the image downloads.
                  // Once loaded, the Image widget will size itself, and the bubble
                  // will adapt to it.
                  loadingBuilder:
                      (
                        BuildContext context,
                        Widget child,
                        ImageChunkEvent? loadingProgress,
                      ) {
                        if (loadingProgress == null) {
                          return child; // Image is loaded, show it.
                        }
                        // Image is still loading, show a placeholder.
                        // This placeholder has a fixed size to prevent the bubble
                        // from collapsing completely before the image loads.
                        return Container(
                          width: 200.w, // A reasonable default width
                          height: 250.w, // A reasonable default height
                          color: AppColors.appBarBackground.withOpacity(0.5),
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: AppColors.secondaryTextColor,
                              size: 50,
                            ),
                          ),
                        );
                      },
                ),
              )
            // This is for the temporary image being sent from the device
            : Image.file(File(message.content)),
      );
    }
    // Return an empty widget for unknown types
    return const SizedBox.shrink();
  }
}
