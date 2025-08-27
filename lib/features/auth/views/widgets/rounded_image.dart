import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';

class RoundedImageNetwork extends StatelessWidget {
  final String? imageUrl;
  const RoundedImageNetwork({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 100.r,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Icon(Icons.person, color: AppColors.accentColor, size: 100.r)
          : null,
    );
  }
}

class RoundedImageFile extends StatelessWidget {
  final PlatformFile? image;
  const RoundedImageFile({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 100.r,
      backgroundImage: image != null ? FileImage(File(image!.path!)) : null,
      child: image == null
          ? Icon(Icons.person, color: AppColors.accentColor, size: 100.r)
          : null,
    );
  }
}
