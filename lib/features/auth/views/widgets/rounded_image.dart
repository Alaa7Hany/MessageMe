import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';

class RoundedImageNetwork extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  const RoundedImageNetwork({super.key, this.imageUrl, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius.r,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Icon(Icons.person, color: AppColors.accentColor, size: radius.r)
          : null,
    );
  }
}

class RoundedImageFile extends StatelessWidget {
  final PlatformFile? image;
  final bool isGroup;
  final double radius;

  const RoundedImageFile({
    super.key,
    this.image,
    required this.radius,
    this.isGroup = false,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius.r,
      backgroundImage: image != null ? FileImage(File(image!.path!)) : null,
      child: image == null
          ? Icon(
              isGroup ? Icons.group : Icons.person,
              color: AppColors.accentColor,
              size: radius.r,
            )
          : null,
    );
  }
}
