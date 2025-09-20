import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart'; // Add this import
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
                // Replace Image.network with CachedNetworkImage
                child: CachedNetworkImage(
                  imageUrl: message.content,
                  fadeOutDuration: const Duration(milliseconds: 100),
                  fadeInDuration: const Duration(milliseconds: 100),
                  placeholderFadeInDuration: const Duration(milliseconds: 100),
                  fadeInCurve: Curves.easeIn,
                  fadeOutCurve: Curves.easeOut,

                  fit: BoxFit.cover,
                  // This placeholder is robust and will be shown from the first frame.
                  placeholder: (context, url) => Container(
                    // Give the placeholder a default size
                    width: 200.w,
                    height: 250.w,
                    color: AppColors.appBarBackground.withOpacity(0.5),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: AppColors.secondaryTextColor,
                        size: 50,
                      ),
                    ),
                  ),
                  // Optional: Show an error icon if the image fails to load
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.error, color: AppColors.error, size: 50),
                  ),
                ),
              )
            : Image.file(File(message.content)),
      );
    }
    return const SizedBox.shrink();
  }
}
