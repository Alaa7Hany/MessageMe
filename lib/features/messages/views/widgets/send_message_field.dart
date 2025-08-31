import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:message_me/core/cubit/connectivity_cubit/connectivity_state.dart';
import '../../../../core/cubit/connectivity_cubit/connectivity_cubit.dart';
import '../../../../core/utils/app_colors.dart';

import '../../../../core/utils/app_text_styles.dart';

class SendMessageField extends StatelessWidget {
  final TextEditingController controller;
  final void Function()? onSendText;
  final void Function()? onSendImage;

  const SendMessageField({
    super.key,
    required this.controller,
    this.onSendText,
    this.onSendImage,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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
        suffixIcon: BlocBuilder<ConnectivityCubit, ConnectivityState>(
          builder: (context, state) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: state is ConnectivityDisconnected
                      ? null
                      : onSendImage,

                  color: Colors.blueAccent,
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, child) {
                    // The 'value' is the current state of the controller
                    final bool canSend =
                        value.text.isNotEmpty &&
                        state is! ConnectivityDisconnected;

                    return IconButton(
                      // Enable/disable based on the controller's text
                      onPressed: canSend ? onSendText : null,
                      icon: Icon(
                        Icons.send,
                        // Change color based on the enabled state
                        color: canSend ? AppColors.accentColor : Colors.grey,
                      ),
                    );
                  },
                ),
              ],
            );
          },
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
