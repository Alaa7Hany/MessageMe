import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart'; // Make sure you have this file with your colors

class AppTextStyles {
  AppTextStyles._();

  // -- Font Size 12: For small text like timestamps or captions --
  static TextStyle f12w400primary() {
    return TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.primaryTextColor,
    );
  }

  static TextStyle f12w400secondary() {
    return TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.secondaryTextColor,
    );
  }

  static TextStyle f12w400error() {
    return TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.error,
    );
  }

  // -- Font Size 14: For standard body text and buttons --
  static TextStyle f14w400primary() {
    // Use for general body text
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.primaryTextColor,
    );
  }

  static TextStyle f14w400secondary() {
    // Use for subtitles or less important body text (e.g., last message preview)
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.secondaryTextColor,
    );
  }

  static TextStyle f14w400error() {
    // Use for error messages
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.error,
    );
  }

  static TextStyle f14w600primary() {
    // Use for button text or small emphasized text
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600, // Semi-bold
      color: AppColors.primaryTextColor,
    );
  }

  static TextStyle f14w600accent() {
    // Use for accent-colored text like links or special buttons
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.accentColor, // Assuming you have an accent color
    );
  }

  // -- Font Size 16: For list titles and input fields --
  static TextStyle f16w400primary() {
    // Use for main message text inside chat bubbles and for text input fields
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.primaryTextColor,
    );
  }

  static TextStyle f16w500primary() {
    // Use for list item titles, like usernames on the main chat list
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500, // Medium
      color: AppColors.primaryTextColor,
    );
  }

  // -- Font Size 18: For page titles --
  static TextStyle f18w600primary() {
    // Use for AppBar titles
    return TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600, // Semi-bold
      color: AppColors.primaryTextColor,
    );
  }

  // -- Font Size 24: For major headings --
  static TextStyle f24w700primary() {
    // Use for large screen headings (e.g., "Sign In")
    return TextStyle(
      fontSize: 24.sp,
      fontWeight: FontWeight.w700, // Bold
      color: AppColors.primaryTextColor,
    );
  }
}
