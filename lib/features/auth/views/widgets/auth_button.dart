import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';

class AuthButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  const AuthButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentColor,
          disabledBackgroundColor: AppColors.appBarBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(vertical: 15.h),
        ),
        child: Text(label, style: AppTextStyles.f16w500primary()),
      ),
    );
  }
}
