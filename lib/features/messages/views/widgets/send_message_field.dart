import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:message_me/core/utils/app_colors.dart';

import '../../../../core/utils/app_text_styles.dart';

class SendMessageField extends StatelessWidget {
  const SendMessageField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      textAlign: TextAlign.start,
      style: AppTextStyles.f14w400primary(),
      minLines: 1,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Type a message',
        hintStyle: AppTextStyles.f14w400secondary(),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          vertical: 12.0.h,
          horizontal: 10.0.w,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.image, color: Colors.blueAccent),
            Icon(Icons.send, color: AppColors.accentColor),
          ],
        ),

        suffixIconConstraints: BoxConstraints(minWidth: 70.w),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.accentColor, width: 1.5.w),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.appBarBackground, width: 1.w),
        ),
      ),
    );
  }
}
