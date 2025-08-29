import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  const SearchField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      textAlign: TextAlign.start,
      style: AppTextStyles.f14w400primary(),
      minLines: 1,
      maxLines: 1,
      decoration: InputDecoration(
        hintText: 'Search',
        filled: true,
        fillColor: AppColors.scaffoldBackground,
        hintStyle: AppTextStyles.f14w400secondary(),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          vertical: 12.0.h,
          horizontal: 10.0.w,
        ),
        suffixIcon: Icon(Icons.search, color: AppColors.accentColor),

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
