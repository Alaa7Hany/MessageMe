import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class MyElevatedButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  final Color color;

  const MyElevatedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = AppColors.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: AppColors.appBarBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 5.w),
        ),
        child: Text(
          label,
          style: AppTextStyles.f16w500primary(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
