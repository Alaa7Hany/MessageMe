import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:message_me/core/utils/app_text_styles.dart';

import '../utils/app_colors.dart';

class MyTextformField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final bool isObsecure;
  final Widget? suffixIcon;

  const MyTextformField({
    super.key,
    required this.label,
    required this.controller,
    required this.validator,
    this.isObsecure = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTapOutside: (event) => FocusScope.of(context).unfocus(),

      validator: validator,
      controller: controller,
      decoration: _textFieldDecoration(),
      autovalidateMode: AutovalidateMode.onUnfocus,
      obscureText: isObsecure,
      style: AppTextStyles.f14w400primary(),
    );
  }

  InputDecoration _textFieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.appBarBackground,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.accentColor, width: 2.0.r),
        borderRadius: BorderRadius.circular(10.0.r),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.appBarBackground, width: 2.0.r),
        borderRadius: BorderRadius.circular(10.0.r),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.error, width: 2.0.r),
        borderRadius: BorderRadius.circular(10.0.r),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.error, width: 2.0.r),
        borderRadius: BorderRadius.circular(10.0.r),
      ),
      labelText: label,
      labelStyle: AppTextStyles.f14w400secondary(),
      suffixIcon: suffixIcon,
      errorStyle: AppTextStyles.f12w400error(),
    );
  }
}
